//
//  remndTests.swift
//  remndTests
//
//  Created by Shafayet Ul Islam on 19/9/2026.
//

import Foundation
import Testing
@testable import remnd

@MainActor
struct remndTests {
    private var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(identifier: "Australia/Adelaide")!
        return value
    }

    private func localDate(_ day: Int, hour: Int, minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(
            year: 2026,
            month: 9,
            day: day,
            hour: hour,
            minute: minute
        ))!
    }

    @Test func streakUsesFullLocalDays() {
        let store = AppDataStore(defaults: nil, now: localDate(27, hour: 23), calendar: calendar)
        let target = store.totalCards

        for _ in 0..<(target - 1) {
            store.completeCard(at: localDate(27, hour: 23))
        }
        #expect(store.streak(asOf: localDate(27, hour: 23, minute: 58)) == 0)

        store.completeCard(at: localDate(27, hour: 23, minute: 59))
        #expect(store.streak(asOf: localDate(27, hour: 23, minute: 59)) == 1)

        store.refreshForToday(at: localDate(28, hour: 0, minute: 1))
        #expect(store.streak(asOf: localDate(28, hour: 0, minute: 1)) == 1)
        #expect(store.completedCount == 0)

        store.refreshForToday(at: localDate(29, hour: 0, minute: 1))
        #expect(store.streak(asOf: localDate(29, hour: 0, minute: 1)) == 0)
    }

    @Test func progressAndPersonalDuasSurviveRelaunch() {
        let suite = "remnd.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let day = localDate(27, hour: 10)
        let store = AppDataStore(defaults: defaults, now: day, calendar: calendar)
        let personalDua = Dua(
            id: "personal-test",
            title: "Personal dua",
            arabic: "دُعَاءٌ",
            transliteration: nil,
            translation: "A supplication",
            benefit: "Remembrance"
        )

        store.addPersonalDua(personalDua, at: day)
        store.updateProfile(username: "Sam", bio: "Daily remembrance")
        store.submitForReview(personalDua, at: day)
        store.completeCard(at: day)

        let reopened = AppDataStore(defaults: defaults, now: day, calendar: calendar)
        #expect(reopened.profile.username == "Sam")
        #expect(reopened.customDuas.contains { $0.id == personalDua.id })
        #expect(reopened.userDuas.contains { $0.duaID == personalDua.id })
        #expect(reopened.pendingSubmissions.count == 1)
        #expect(reopened.completedCount == 1)
        #expect(reopened.totalCards == store.totalCards)
    }

    @Test func consecutiveCompletedDaysIncreaseStreakOncePerDay() {
        let firstDay = localDate(27, hour: 9)
        let store = AppDataStore(defaults: nil, now: firstDay, calendar: calendar)

        for _ in 0..<store.totalCards { store.completeCard(at: firstDay) }
        store.completeCard(at: firstDay)
        #expect(store.streak(asOf: firstDay) == 1)

        let secondDay = localDate(28, hour: 9)
        store.refreshForToday(at: secondDay)
        for _ in 0..<store.totalCards { store.completeCard(at: secondDay) }
        #expect(store.streak(asOf: secondDay) == 2)

        store.refreshForToday(at: localDate(29, hour: 9))
        #expect(store.streak(asOf: localDate(29, hour: 9)) == 2)
    }

    @Test func configurationChangesWaitUntilNextDayAfterFirstCard() {
        let firstDay = localDate(27, hour: 10)
        let store = AppDataStore(defaults: nil, now: firstDay, calendar: calendar)
        let originalTarget = store.totalCards
        store.completeCard(at: firstDay)

        var updated = store.userDuas
        updated[0].repetitionCount += 2
        store.setUserDuas(updated, at: firstDay)

        #expect(store.totalCards == originalTarget)
        #expect(store.hasPendingConfiguration)

        store.refreshForToday(at: localDate(28, hour: 1))
        #expect(store.totalCards == originalTarget + 2)
        #expect(store.completedCount == 0)
        #expect(!store.hasPendingConfiguration)
    }
}
