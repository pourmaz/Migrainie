import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showLogSheet = false
    @EnvironmentObject var healthKit: HealthKitManager

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 18) {
                        headerCard
                        summaryCard
                        healthStatusCard
                        recentAttacksCard
                    }
                    .padding()
                }
            }
            .navigationTitle("Home")
            .toolbar {
                // 👤 Top-left: link to Profile
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        ProfileView()
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(AppTheme.primary)
                    }
                }
                
                // ➕ Top-right: quick log
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showLogSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .sheet(isPresented: $showLogSheet) {
                LogMigraineView()
            }
        }
    }
    
    
    private var healthStatusCard: some View {
        HStack {
            Image(systemName: healthKit.isAuthorized ? "heart.fill" : "heart.slash")
                .foregroundColor(AppTheme.primary)
            Text(healthKit.isAuthorized ? "Apple Health connected" : "Apple Health not connected")
                .font(.callout)
                .foregroundColor(.secondary)
            Spacer()
            if !healthKit.isAuthorized {
                NavigationLink("Connect") {
                    SettingsView()
                }
                .foregroundColor(AppTheme.primary)
                .font(.callout.weight(.semibold))
            }
        }
        .cardStyle()
    }

    private var recentAttacks: [MigraineAttack] {
        Array(appState.attacks.sorted { $0.startDate > $1.startDate }.prefix(3))
    }
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(appState.profile.username.isEmpty
                 ? "How’s your head today?"
                 : "Hi \(appState.profile.username), how’s your head today?")
                .font(.title2.bold())
            
            Text("Log any migraine as soon as it starts, so Migrainie can help you find patterns over time.")
                .font(.callout)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Button {
                showLogSheet = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Log a migraine now")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.primary)
                .foregroundColor(.white)
                .cornerRadius(AppTheme.cornerRadius)
            }
            .buttonStyle(.plain)
        }
        .cardStyle()
    }
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Last 30 days")
                .font(.headline)
            Text("Migraine days: \(appState.migraineDaysLast30)")
                .font(.title3.bold())
            Text("Total attacks logged: \(appState.attacks.count)")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .cardStyle()
    }
    
    private var recentAttacksCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent attacks")
                .font(.headline)
            
            if appState.attacks.isEmpty {
                Text("No attacks logged yet. Tap the button above when your next migraine starts.")
                    .font(.callout)
                    .foregroundColor(.secondary)
            } else {
                ForEach(recentAttacks) { attack in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(attack.startDate, style: .date)
                                    .font(.subheadline)
                                
                                Text("Severity \(attack.severity)/10")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if attack.hasAura {
                                Text("Aura")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AppTheme.secondary.opacity(0.3))
                                    .foregroundColor(AppTheme.primary)
                                    .cornerRadius(10)
                            }
                        }
                        
                        if let ctx = attack.linkedContextSnapshot {
                            let sleep = String(format: "%.1f", ctx.sleepHours ?? 0)
                            let steps = Int(ctx.steps ?? 0)
                            let hr = Int(ctx.avgHeartRateBpm ?? 0)

                            Text(verbatim: "Sleep \(sleep)h • Steps \(steps) • HR \(hr)")

                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .cardStyle()
    }
}

