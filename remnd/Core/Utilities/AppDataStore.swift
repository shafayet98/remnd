import Foundation
import Combine
import SwiftUI

struct UserProfile: Codable, Equatable {
    var username = "Your Name"
    var bio = ""
    var avatarColorHex = "D9466F"
}

struct DailyActivity: Codable, Equatable {
    let dayKey: String
    var goal: Int
    var completed: Int

    var isComplete: Bool { goal > 0 && completed >= goal }
}

struct PendingDuaSubmission: Identifiable, Codable {
    let id: UUID
    let dua: Dua
    let submittedAt: Date
}

private struct DailyDeckSession: Codable, Equatable {
    var dayKey: String
    var userDuas: [UserDua]
    var completedCount: Int
}

private struct SavedAppData: Codable {
    var userDuas: [UserDua]
    var customDuas: [Dua]
    var pendingSubmissions: [PendingDuaSubmission]
    var profile: UserProfile
    var dailySession: DailyDeckSession
    var activity: [DailyActivity]
    var firstTrackedDate: Date
}

@MainActor
final class AppDataStore: ObservableObject {
    @Published private(set) var userDuas: [UserDua]
    @Published private(set) var customDuas: [Dua]
    @Published private(set) var pendingSubmissions: [PendingDuaSubmission]
    @Published private(set) var profile: UserProfile
    @Published private(set) var activity: [DailyActivity]
    @Published private var dailySession: DailyDeckSession

    let firstTrackedDate: Date

    private let defaults: UserDefaults?
    private let calendar: Calendar
    private let storageKey = "remnd.appData.v1"

    init(
        defaults: UserDefaults? = .standard,
        now: Date = .now,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        self.defaults = defaults
        self.calendar = calendar

        let saved = defaults?.data(forKey: storageKey)
            .flatMap { try? JSONDecoder().decode(SavedAppData.self, from: $0) }
        let initialDuas = saved?.userDuas ?? MockData.userDuas
        let dayKey = Self.dayKey(for: now, calendar: calendar)

        userDuas = initialDuas
        customDuas = saved?.customDuas ?? []
        pendingSubmissions = saved?.pendingSubmissions ?? []
        profile = saved?.profile ?? UserProfile()
        activity = saved?.activity ?? []
        dailySession = saved?.dailySession ?? DailyDeckSession(
            dayKey: dayKey,
            userDuas: initialDuas,
            completedCount: 0
        )
        firstTrackedDate = saved?.firstTrackedDate ?? calendar.startOfDay(for: now)

        refreshForToday(at: now)
    }

    var allDuas: [Dua] { MockData.duas + customDuas }

    var totalCards: Int {
        DeckBuilder.build(userDuas: dailySession.userDuas, duas: allDuas).count
    }

    var completedCount: Int { min(dailySession.completedCount, totalCards) }

    var remainingCards: [DuaCardItem] {
        Array(
            DeckBuilder.build(userDuas: dailySession.userDuas, duas: allDuas)
                .dropFirst(completedCount)
        )
    }

    var hasPendingConfiguration: Bool {
        completedCount > 0 && dailySession.userDuas != userDuas
    }

    func refreshForToday(at now: Date = .now) {
        let todayKey = Self.dayKey(for: now, calendar: calendar)
        if dailySession.dayKey != todayKey {
            dailySession = DailyDeckSession(
                dayKey: todayKey,
                userDuas: userDuas,
                completedCount: 0
            )
        }
        updateTodayActivity()
    }

    func setUserDuas(_ updated: [UserDua]) {
        setUserDuas(updated, at: .now)
    }

    func setUserDuas(_ updated: [UserDua], at now: Date) {
        refreshForToday(at: now)
        userDuas = updated

        // A started deck stays fixed until the next local day.
        if dailySession.completedCount == 0 {
            dailySession.userDuas = updated
            updateTodayActivity()
        } else {
            persist()
        }
    }

    func completeCard(at now: Date = .now) {
        refreshForToday(at: now)
        guard totalCards > 0, dailySession.completedCount < totalCards else { return }
        dailySession.completedCount += 1
        updateTodayActivity()
    }

    func updateProfile(username: String, bio: String) {
        profile.username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.bio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        persist()
    }

    func updateAvatarColor(_ hex: String) {
        profile.avatarColorHex = hex
        persist()
    }

    func addPersonalDua(_ dua: Dua, at now: Date = .now) {
        customDuas.append(dua)
        let nextPosition = (userDuas.map(\.position).max() ?? -1) + 1
        setUserDuas(
            userDuas + [UserDua(
                id: UUID(),
                duaID: dua.id,
                repetitionCount: 1,
                position: nextPosition
            )],
            at: now
        )
    }

    func submitForReview(_ dua: Dua, at date: Date = .now) {
        pendingSubmissions.append(
            PendingDuaSubmission(id: UUID(), dua: dua, submittedAt: date)
        )
        persist()
    }

    func activity(on date: Date) -> DailyActivity? {
        let key = Self.dayKey(for: date, calendar: calendar)
        return activity.first { $0.dayKey == key }
    }

    func streak(asOf now: Date = .now) -> Int {
        let today = calendar.startOfDay(for: now)
        let startingDay: Date
        if activity(on: today)?.isComplete == true {
            startingDay = today
        } else {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
                return 0
            }
            startingDay = yesterday
        }

        var count = 0
        var day = startingDay
        while activity(on: day)?.isComplete == true {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else {
                break
            }
            day = previous
        }
        return count
    }

    static func dayKey(for date: Date, calendar: Calendar = .autoupdatingCurrent) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%04d-%02d-%02d",
            parts.year ?? 0,
            parts.month ?? 0,
            parts.day ?? 0
        )
    }

    private func updateTodayActivity() {
        let updated = DailyActivity(
            dayKey: dailySession.dayKey,
            goal: totalCards,
            completed: completedCount
        )
        if let index = activity.firstIndex(where: { $0.dayKey == updated.dayKey }) {
            guard activity[index] != updated else { return }
            activity[index] = updated
        } else {
            activity.append(updated)
        }
        persist()
    }

    private func persist() {
        guard let defaults else { return }
        let saved = SavedAppData(
            userDuas: userDuas,
            customDuas: customDuas,
            pendingSubmissions: pendingSubmissions,
            profile: profile,
            dailySession: dailySession,
            activity: activity,
            firstTrackedDate: firstTrackedDate
        )
        guard let data = try? JSONEncoder().encode(saved) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
