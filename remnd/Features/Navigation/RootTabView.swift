import SwiftUI

private enum AppTab: String, CaseIterable, Hashable {
    case discovery = "Discovery"
    case home = "Home"
    case profile = "Profile"
    case settings = "Settings"

    var symbol: String {
        switch self {
        case .discovery: "safari"
        case .home: "house"
        case .profile: "person.crop.circle"
        case .settings: "gearshape"
        }
    }
}

struct RootTabView: View {
    @State private var selectedTab: AppTab = .home
    @StateObject private var store: AppDataStore
    @Environment(\.scenePhase) private var scenePhase
    @Namespace private var tabSelectionAnimation
    #if DEBUG
    @AppStorage("remnd.debugPreviewNightTheme") private var previewNightTheme = false
    #endif
    private let suggestedUsername: String?
    private let onSignOut: (() -> Void)?
    private let signOutTitle: String

    init(
        appleUserID: String? = nil,
        suggestedUsername: String? = nil,
        onSignOut: (() -> Void)? = nil,
        signOutTitle: String = "Sign Out"
    ) {
        _store = StateObject(wrappedValue: AppDataStore(appleUserID: appleUserID))
        self.suggestedUsername = suggestedUsername
        self.onSignOut = onSignOut
        self.signOutTitle = signOutTitle
    }

    private var userDuasBinding: Binding<[UserDua]> {
        Binding(
            get: { store.userDuas },
            set: { store.setUserDuas($0) }
        )
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { timeline in
            let palette = palette(for: timeline.date)
            ZStack {
                Rectangle()
                    .fill(palette.background)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    tabContent(now: timeline.date)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    tabBar(palette: palette)
                }
            }
            .environment(\.appPalette, palette)
            .environment(\.colorScheme, palette.isDaytime ? .light : .dark)
            .onAppear { store.refreshForToday(at: timeline.date) }
            .onAppear {
                if let suggestedUsername,
                   store.profile.username == "Your Name" {
                    store.updateProfile(username: suggestedUsername, bio: store.profile.bio)
                }
            }
            .onChange(of: AppDataStore.dayKey(for: timeline.date)) { _, _ in
                store.refreshForToday(at: timeline.date)
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { store.refreshForToday() }
            }
        }
    }

    private func palette(for date: Date) -> AppPalette {
        #if DEBUG
        AppPalette(date: date, forceNight: previewNightTheme)
        #else
        AppPalette(date: date)
        #endif
    }

    private func tabContent(now: Date) -> some View {
        ZStack {
            DiscoveryView(userDuas: userDuasBinding)
                .opacity(selectedTab == .discovery ? 1 : 0)
                .allowsHitTesting(selectedTab == .discovery)
                .accessibilityHidden(selectedTab != .discovery)

            MyDuasView(store: store)
                .opacity(selectedTab == .home ? 1 : 0)
                .allowsHitTesting(selectedTab == .home)
                .accessibilityHidden(selectedTab != .home)

            ProfileView(store: store, now: now, onSignOut: onSignOut, signOutTitle: signOutTitle)
                .opacity(selectedTab == .profile ? 1 : 0)
                .allowsHitTesting(selectedTab == .profile)
                .accessibilityHidden(selectedTab != .profile)

            SettingsView(userDuas: userDuasBinding, duas: store.allDuas)
                .opacity(selectedTab == .settings ? 1 : 0)
                .allowsHitTesting(selectedTab == .settings)
                .accessibilityHidden(selectedTab != .settings)
        }
    }

    private func tabBar(palette: AppPalette) -> some View {
        HStack(spacing: 6) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                let isSelected = selectedTab == tab

                Button {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    }
                    .foregroundStyle(isSelected ? palette.activeTab : palette.inactiveTab)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay {
                                    if palette.isDaytime {
                                        Capsule()
                                            .fill(palette.smallButton.opacity(0.68))
                                    }
                                }
                                .overlay {
                                    Capsule()
                                        .strokeBorder(
                                            palette.isDaytime
                                                ? palette.card.opacity(0.6)
                                                : palette.cardBorder.opacity(0.4),
                                            lineWidth: 1
                                        )
                                }
                                .matchedGeometryEffect(
                                    id: "selected-tab-glass",
                                    in: tabSelectionAnimation
                                )
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.rawValue)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(8)
        .appGlassBackground(palette.navigationBar, in: Capsule(), palette: palette)
        .overlay {
            if !palette.isDaytime {
                Capsule().strokeBorder(palette.cardBorder, lineWidth: 1)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
        .padding(.bottom, 4)
        .background {
            Rectangle()
                .fill(palette.tabBarSurround)
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    RootTabView()
}
