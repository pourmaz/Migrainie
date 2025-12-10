import SwiftUI

@main
struct MigrainieApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
                .onAppear {
                    // Optional: only if you want to ask early
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        if settings.authorizationStatus == .notDetermined {
                            NotificationManager.shared.requestAuthorization { _ in }
                        }
                    }
                }
        }
    }
}
