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
    @State private var userDuas = MockData.userDuas
    @Namespace private var tabSelectionAnimation

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { timeline in
            let palette = AppPalette(date: timeline.date)
            ZStack {
                Rectangle()
                    .fill(palette.background)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    tabContent(palette: palette)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    tabBar(palette: palette)
                }
            }
            .environment(\.appPalette, palette)
            .environment(\.colorScheme, palette.isDaytime ? .light : .dark)
        }
    }

    private func tabContent(palette: AppPalette) -> some View {
        ZStack {
            DiscoveryView(userDuas: $userDuas)
                .opacity(selectedTab == .discovery ? 1 : 0)
                .allowsHitTesting(selectedTab == .discovery)
                .accessibilityHidden(selectedTab != .discovery)

            MyDuasView(userDuas: $userDuas)
                .opacity(selectedTab == .home ? 1 : 0)
                .allowsHitTesting(selectedTab == .home)
                .accessibilityHidden(selectedTab != .home)

            PlaceholderTabView(title: "Profile", palette: palette)
                .opacity(selectedTab == .profile ? 1 : 0)
                .allowsHitTesting(selectedTab == .profile)
                .accessibilityHidden(selectedTab != .profile)

            SettingsView(userDuas: $userDuas)
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
                                    Capsule()
                                        .fill(palette.smallButton.opacity(0.68))
                                }
                                .overlay {
                                    Capsule()
                                        .strokeBorder(
                                            palette.card.opacity(palette.isDaytime ? 0.6 : 0.12),
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
        .background(palette.navigationBar, in: Capsule())
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

private struct PlaceholderTabView: View {
    let title: String
    let palette: AppPalette

    var body: some View {
        NavigationStack {
            Rectangle()
                .fill(palette.background)
                .ignoresSafeArea()
                .navigationTitle(title)
                .toolbarBackground(palette.navigationBar, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    RootTabView()
}
