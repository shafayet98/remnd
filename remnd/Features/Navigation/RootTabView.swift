import SwiftUI

private enum AppTab: Hashable {
    case discovery
    case home
    case profile
    case settings
}

struct RootTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            PlaceholderTabView(title: "Discovery")
                .tabItem {
                    Label("Discovery", systemImage: "safari")
                }
                .tag(AppTab.discovery)

            MyDuasView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(AppTab.home)

            PlaceholderTabView(title: "Profile")
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(AppTab.profile)

            PlaceholderTabView(title: "Settings")
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(AppTab.settings)
        }
        .tint(.brandClrSecondary)
        .toolbarBackground(.white, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

private struct PlaceholderTabView: View {
    let title: String

    var body: some View {
        NavigationStack {
            Color.remndScreenBackground
                .ignoresSafeArea()
                .navigationTitle(title)
        }
    }
}

#Preview {
    RootTabView()
}
