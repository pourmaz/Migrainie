import SwiftUI

struct MainTabView: View {
    enum Tab: Hashable {
        case insights
        case home
        case settings
    }

    @State private var selection: Tab = .home   // ✅ Home opens first

    var body: some View {
        TabView(selection: $selection) {
            InsightsView()
                .tabItem { Label("Insights", systemImage: "chart.bar.xaxis") }
                .tag(Tab.insights)

            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(Tab.home)

            SettingsView()
                .tabItem { Label("More", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
        .tint(AppTheme.primary)
    }
}
