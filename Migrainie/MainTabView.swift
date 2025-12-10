import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // Left tab
            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.xaxis")
                }
            
            // Middle tab – Home
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            // Right tab
            SettingsView()
                .tabItem {
                    Label("More", systemImage: "gearshape")
                }
        }
        .tint(AppTheme.primary)
    }
}
