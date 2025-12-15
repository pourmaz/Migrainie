import SwiftUI
import UserNotifications

@main
struct MigrainieApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var healthKit = HealthKitManager.shared   // ✅ ADD
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
                .environmentObject(healthKit)                     // ✅ ADD
                .onAppear {
                    // Ask for notification permission if not decided yet
                    UNUserNotificationCenter.current()
                        .getNotificationSettings { settings in
                            if settings.authorizationStatus == .notDetermined {
                                NotificationManager.shared
                                    .requestAuthorization { _ in }
                            }
                        }
                }
        }
    }
}
