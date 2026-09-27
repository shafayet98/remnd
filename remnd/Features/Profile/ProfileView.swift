import SwiftUI

private struct AvatarSwatch: Identifiable {
    let name: String
    let hex: String
    let color: Color

    var id: String { hex }

    static let all: [AvatarSwatch] = [
        .init(name: "Rose", hex: "D9466F", color: Color(red: 0.85, green: 0.27, blue: 0.44)),
        .init(name: "Coral", hex: "E26D5C", color: Color(red: 0.89, green: 0.43, blue: 0.36)),
        .init(name: "Amber", hex: "E2B04A", color: Color(red: 0.89, green: 0.69, blue: 0.29)),
        .init(name: "Sage", hex: "7EAA82", color: Color(red: 0.49, green: 0.67, blue: 0.51)),
        .init(name: "Mint", hex: "64A893", color: Color(red: 0.39, green: 0.66, blue: 0.58)),
        .init(name: "Sky", hex: "6E9EC4", color: Color(red: 0.43, green: 0.62, blue: 0.77)),
        .init(name: "Lilac", hex: "9C82C7", color: Color(red: 0.61, green: 0.51, blue: 0.78)),
        .init(name: "Plum", hex: "9A607F", color: Color(red: 0.60, green: 0.38, blue: 0.50))
    ]

    static func color(for hex: String) -> Color {
        all.first(where: { $0.hex == hex })?.color ?? all[0].color
    }
}

private enum ActivityDayStatus: Equatable {
    case complete, partial, missed, noData
}

struct ProfileView: View {
    @Environment(\.appPalette) private var palette
    @ObservedObject var store: AppDataStore
    var now: Date = .now

    @State private var showingProfileEditor = false
    @State private var showingColorPalette = false
    @State private var draftUsername = ""
    @State private var draftBio = ""

    private let calendar = Calendar.autoupdatingCurrent

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    profileCard
                    streakCard
                    publishLink
                    weeklyChart
                    monthlyChart

                    if !store.pendingSubmissions.isEmpty {
                        pendingReviewCard
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
            .background {
                Rectangle()
                    .fill(palette.background)
                    .ignoresSafeArea()
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingProfileEditor) { profileEditor }
            .sheet(isPresented: $showingColorPalette) { colorPalette }
        }
    }

    private var profileCard: some View {
        HStack(alignment: .top, spacing: 18) {
            Button { showingColorPalette = true } label: {
                Circle()
                    .fill(AvatarSwatch.color(for: store.profile.avatarColorHex))
                    .frame(width: 76, height: 76)
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "paintpalette.fill")
                            .font(.caption)
                            .foregroundStyle(palette.smallButtonIcon)
                            .padding(7)
                            .background(palette.smallButton, in: Circle())
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Choose profile color")

            Button(action: beginEditingProfile) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(store.profile.username.isEmpty ? "Your Name" : store.profile.username)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(palette.primaryText)

                    Text(store.profile.bio.isEmpty ? "Tap to add a bio" : store.profile.bio)
                        .font(.subheadline)
                        .foregroundStyle(palette.hintText)
                        .multilineTextAlignment(.leading)

                    Label("Edit profile", systemImage: "pencil")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(palette.activeTab)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Edit username and bio")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .profileCardStyle(palette: palette)
    }

    private var streakCard: some View {
        HStack(spacing: 12) {
            Text("🍃")
                .font(.largeTitle)
            VStack(alignment: .leading, spacing: 3) {
                Text("\(store.streak(asOf: now)) day streak")
                    .font(.headline)
                    .foregroundStyle(palette.primaryText)
                Text("Complete every Home card each local day")
                    .font(.caption)
                    .foregroundStyle(palette.hintText)
            }
            Spacer(minLength: 0)
        }
        .padding(18)
        .profileCardStyle(palette: palette)
    }

    private var publishLink: some View {
        NavigationLink {
            NewDuaView(store: store)
        } label: {
            HStack {
                Label("Publish new Dua", systemImage: "plus.circle.fill")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .font(.headline)
            .foregroundStyle(palette.counterText)
            .padding(18)
            .background(palette.activeTab, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Last 7 days")
                .font(.headline)
                .foregroundStyle(palette.primaryText)
            Text("Cards completed out of each day’s target")
                .font(.caption)
                .foregroundStyle(palette.hintText)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(days(count: 7), id: \.self) { day in
                    let record = store.activity(on: day)
                    let goal = record?.goal ?? 0
                    let completed = record?.completed ?? 0

                    VStack(spacing: 7) {
                        Text("\(completed)")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(palette.primaryText)

                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(palette.smallButton)
                                .frame(height: 92)
                            RoundedRectangle(cornerRadius: 7)
                                .fill(palette.activeTab)
                                .frame(height: goal > 0 ? 92 * CGFloat(completed) / CGFloat(goal) : 0)
                        }

                        Text(day.formatted(.dateTime.weekday(.narrow)))
                            .font(.caption2)
                            .foregroundStyle(palette.hintText)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(day.formatted(date: .abbreviated, time: .omitted)): \(completed) of \(goal) cards")
                }
            }
        }
        .padding(20)
        .profileCardStyle(palette: palette)
    }

    private var monthlyChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Last 30 days")
                .font(.headline)
                .foregroundStyle(palette.primaryText)
            Text("Full-deck days and days in progress")
                .font(.caption)
                .foregroundStyle(palette.hintText)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 7), count: 7), spacing: 7) {
                ForEach(days(count: 30), id: \.self) { day in
                    let record = store.activity(on: day)
                    let status = dayStatus(day, record: record)
                    let color: Color = if status == .complete {
                        palette.activeTab
                    } else if status == .partial {
                        palette.smallButtonIcon
                    } else if status == .missed {
                        palette.hintText.opacity(0.55)
                    } else {
                        palette.smallButton
                    }

                    Text(day.formatted(.dateTime.day()))
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(status == .complete ? palette.counterText : palette.primaryText)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .background(color, in: RoundedRectangle(cornerRadius: 9))
                        .accessibilityLabel("\(day.formatted(date: .abbreviated, time: .omitted)): \(dayDescription(status))")
                }
            }

            HStack(spacing: 12) {
                legend("Complete", color: palette.activeTab)
                legend("Partial", color: palette.smallButtonIcon)
                legend("Missed", color: palette.hintText.opacity(0.55))
            }
            .font(.caption2)
            .foregroundStyle(palette.hintText)
        }
        .padding(20)
        .profileCardStyle(palette: palette)
    }

    private var pendingReviewCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pending review")
                .font(.headline)
                .foregroundStyle(palette.primaryText)
            ForEach(store.pendingSubmissions.reversed()) { submission in
                HStack {
                    Text(submission.dua.title)
                        .foregroundStyle(palette.primaryText)
                    Spacer()
                    Text("Pending")
                        .font(.caption)
                        .foregroundStyle(palette.hintText)
                }
                .font(.subheadline)
            }
        }
        .padding(20)
        .profileCardStyle(palette: palette)
    }

    private var profileEditor: some View {
        NavigationStack {
            Form {
                TextField("Username", text: $draftUsername)
                    .textInputAutocapitalization(.words)

                Section("Bio") {
                    TextEditor(text: $draftBio)
                        .frame(minHeight: 110)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { showingProfileEditor = false }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        store.updateProfile(username: draftUsername, bio: draftBio)
                        showingProfileEditor = false
                    }
                    .disabled(draftUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .tint(palette.activeTab)
    }

    private var colorPalette: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Choose a profile color")
                .font(.headline)
                .foregroundStyle(palette.primaryText)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 18) {
                ForEach(AvatarSwatch.all) { swatch in
                    Button {
                        store.updateAvatarColor(swatch.hex)
                        showingColorPalette = false
                    } label: {
                        Circle()
                            .fill(swatch.color)
                            .frame(width: 54, height: 54)
                            .overlay {
                                if store.profile.avatarColorHex == swatch.hex {
                                    Image(systemName: "checkmark")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(swatch.name)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.card)
        .presentationDetents([.height(290)])
    }

    private func beginEditingProfile() {
        draftUsername = store.profile.username
        draftBio = store.profile.bio
        showingProfileEditor = true
    }

    private func days(count: Int) -> [Date] {
        let today = calendar.startOfDay(for: now)
        return (0..<count).reversed().compactMap {
            calendar.date(byAdding: .day, value: -$0, to: today)
        }
    }

    private func dayStatus(_ day: Date, record: DailyActivity?) -> ActivityDayStatus {
        if record?.isComplete == true { return .complete }
        if (record?.completed ?? 0) > 0 { return .partial }

        let firstDay = calendar.startOfDay(for: store.firstTrackedDate)
        let today = calendar.startOfDay(for: now)
        return day >= firstDay && day < today && (record?.goal ?? 1) > 0
            ? .missed : .noData
    }

    private func dayDescription(_ status: ActivityDayStatus) -> String {
        switch status {
        case .complete: "Complete"
        case .partial: "Partially complete"
        case .missed: "Missed"
        case .noData: "No activity yet"
        }
    }

    private func legend(_ title: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(title)
        }
    }
}

private struct ProfileCardStyle: ViewModifier {
    let palette: AppPalette

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .background(palette.card, in: RoundedRectangle(cornerRadius: 24))
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(palette.cardBorder, lineWidth: 1)
            }
    }
}

private extension View {
    func profileCardStyle(palette: AppPalette) -> some View {
        modifier(ProfileCardStyle(palette: palette))
    }
}

#Preview {
    ProfileView(store: AppDataStore(defaults: nil))
}
