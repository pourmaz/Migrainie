import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showClearAlert = false
    @State private var notificationErrorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        profileCard
                        reminderCard
                        loggingCard
                        dataCard
                        aboutCard
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .alert("Clear all migraine data?",
                   isPresented: $showClearAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    appState.clearAttacks()
                }
            } message: {
                Text("This will remove all migraine attacks you’ve logged so far. Your profile and settings will stay.")
            }
            // React to reminder changes
            .onChange(of: appState.settings.dailyReminderEnabled) { _ in
                handleReminderChange()
            }
            .onChange(of: appState.settings.dailyReminderTime) { _ in
                if appState.settings.dailyReminderEnabled {
                    handleReminderChange()
                }
            }
        }
    }

    // MARK: - Reminder handling

    private func handleReminderChange() {
        notificationErrorMessage = nil

        if appState.settings.dailyReminderEnabled {
            // Ask for permission, then schedule
            NotificationManager.shared.requestAuthorization { granted in
                DispatchQueue.main.async {
                    if granted {
                        NotificationManager.shared.scheduleDailyReminder(
                            at: appState.settings.dailyReminderTime
                        )
                    } else {
                        appState.settings.dailyReminderEnabled = false
                        notificationErrorMessage = "Notifications are not allowed. You can enable them in iOS Settings → Notifications → Migrainie."
                    }
                }
            }
        } else {
            // Toggle off → cancel reminder
            NotificationManager.shared.cancelDailyReminder()
        }
    }
}

// MARK: - Cards

extension SettingsView {

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Profile")
                .font(.headline)

            NavigationLink {
                ProfileView()
            } label: {
                HStack {
                    Image(systemName: "person.crop.circle")
                        .foregroundColor(AppTheme.primary)
                    Text("Edit profile")
                    Spacer()
                }
            }
            .foregroundColor(.primary)
        }
        .cardStyle()
    }

    private var reminderCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Reminders")
                .font(.headline)

            Toggle("Daily reminder to log migraines",
                   isOn: $appState.settings.dailyReminderEnabled)
                .tint(AppTheme.primary)

            DatePicker("Reminder time",
                       selection: $appState.settings.dailyReminderTime,
                       displayedComponents: .hourAndMinute)
                .disabled(!appState.settings.dailyReminderEnabled)

            if let notificationErrorMessage {
                Text(notificationErrorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .cardStyle()
    }

    private var loggingCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Logging preferences")
                .font(.headline)

            Toggle("Ask about aura",
                   isOn: $appState.settings.askAuraByDefault)
                .tint(AppTheme.primary)

            Toggle("Show triggers step",
                   isOn: $appState.settings.showTriggersStep)
                .tint(AppTheme.primary)
        }
        .cardStyle()
    }

    private var dataCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Data")
                .font(.headline)

            Button(role: .destructive) {
                showClearAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Clear all migraine data")
                }
                .foregroundColor(.red)
            }
        }
        .cardStyle()
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About Migrainie")
                .font(.headline)

            Text("Migrainie helps you log migraine attacks and see simple patterns over time. In future versions, it will use your Apple Health data to explore how sleep, activity and stress affect your migraines.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .cardStyle()
    }
}
