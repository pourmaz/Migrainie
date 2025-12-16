import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var healthKit: HealthKitManager
    @EnvironmentObject var appState: AppState

    @State private var reportURL: URL?
    @State private var showShareSheet = false
    @State private var exportErrorMessage: String?

    @State private var showClearAlert = false
    @State private var notificationErrorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        profileCard
                        healthCard
                        reminderCard
                        loggingCard
                        dataCard
                        exportCard
                        aboutCard
                    }

                    .padding()
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = reportURL {
                    ShareSheet(items: [url])
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
            NotificationManager.shared.requestAuthorization { granted in
                DispatchQueue.main.async {
                    if granted {
                        NotificationManager.shared.scheduleDailyReminder(
                            at: appState.settings.dailyReminderTime
                        )
                    } else {
                        appState.settings.dailyReminderEnabled = false
                        notificationErrorMessage =
                        "Notifications are not allowed. You can enable them in iOS Settings → Notifications → Migrainie."
                    }
                }
            }
        } else {
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

    
    private var exportCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Doctor report")
                .font(.headline)

            Button {
                export30DayReport()
            } label: {
                HStack {
                    Image(systemName: "doc.richtext")
                        .foregroundColor(AppTheme.primary)
                    Text("Export 30-day PDF report")
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.primary)

            if let exportErrorMessage {
                Text(exportErrorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
            }
        }
        .cardStyle()
    }

    private func export30DayReport() {
        exportErrorMessage = nil

        let cal = Calendar.current
        let to = Date()
        let from = cal.date(byAdding: .day, value: -30, to: to) ?? to

        let attacks30 = appState.attacks
            .filter { $0.startDate >= from && $0.startDate <= to }
            .sorted(by: { $0.startDate > $1.startDate })

        let input = MigraineReportPDFBuilder.ReportInput(
            profile: appState.profile,
            fromDate: from,
            toDate: to,
            attacks: attacks30
        )

        do {
            let url = try MigraineReportPDFBuilder.buildPDF(input: input)
            reportURL = url
            showShareSheet = true
        } catch {
            exportErrorMessage = "Could not generate the PDF report. Please try again."
            print("PDF export error:", error.localizedDescription)
        }
    }

    private var healthCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Apple Health")
                .font(.headline)

            HStack {
                Text("Status")
                Spacer()
                Text(healthKit.isAuthorized ? "Connected" : "Not connected")
                    .foregroundColor(healthKit.isAuthorized ? AppTheme.primary : .secondary)
            }

            Button {
                healthKit.requestAuthorization { _ in }
            } label: {
                Text(healthKit.isAuthorized ? "Re-check permissions" : "Connect Apple Health")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(AppTheme.cornerRadius)
            }
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
