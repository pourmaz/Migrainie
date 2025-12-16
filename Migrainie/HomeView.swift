import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showLogSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Richer background
                LinearGradient(
                    colors: [AppTheme.background, AppTheme.card.opacity(0.75)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        heroHeader

                        quickActionsRow

                        statsGrid

                        recentAttacksSection
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 👤 Profile shortcut (top-left)
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink { ProfileView() } label: {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(AppTheme.primary)
                            .font(.title3)
                    }
                }

                // ➕ Log shortcut (top-right)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showLogSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppTheme.primary)
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showLogSheet) {
                LogMigraineFlowView()
            }
        }
    }

    // MARK: - Derived data

    private var recentAttacks: [MigraineAttack] {
        Array(appState.attacks.sorted { $0.startDate > $1.startDate }.prefix(5))
    }

    private var lastAttackDateText: String {
        guard let last = appState.attacks.sorted(by: { $0.startDate > $1.startDate }).first else {
            return "None yet"
        }
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: last.startDate)
    }

    private var todayText: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: Date())
    }

    // MARK: - UI blocks

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(appState.profile.username.isEmpty ? "Welcome back" : "Welcome back, \(appState.profile.username)")
                .font(.title.bold())
                .foregroundColor(.primary)

            Text(todayText)
                .font(.callout)
                .foregroundColor(.secondary)

            Text("Log migraines quickly and build a clear record you can share with your doctor.")
                .font(.callout)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                showLogSheet = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                    Text("Log a migraine now")
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                }
                .padding()
                .foregroundColor(.white)
                .background(
                    LinearGradient(
                        colors: [AppTheme.primary, AppTheme.secondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(AppTheme.cornerRadius)
            }
            .buttonStyle(.plain)
        }
        .cardStyle()
    }

    private var quickActionsRow: some View {
        HStack(spacing: 12) {
            quickActionCard(
                title: "Log",
                subtitle: "Start/end time",
                systemImage: "plus.circle",
                action: { showLogSheet = true }
            )

            NavigationLink {
                ProfileView()
            } label: {
                quickActionCardView(
                    title: "Profile",
                    subtitle: "Basics & meds",
                    systemImage: "person.text.rectangle"
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func quickActionCard(title: String, subtitle: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            quickActionCardView(title: title, subtitle: subtitle, systemImage: systemImage)
        }
        .buttonStyle(.plain)
    }

    private func quickActionCardView(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundColor(AppTheme.primary)
                .frame(width: 34, height: 34)
                .background(AppTheme.background.opacity(0.9))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(AppTheme.card)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private var statsGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Overview")
                .font(.headline)
                .foregroundColor(.primary)

            HStack(spacing: 12) {
                statTile(
                    title: "30-day\nmigraine days",
                    value: "\(appState.migraineDaysLast30)",
                    systemImage: "calendar"
                )

                statTile(
                    title: "Total\nattacks",
                    value: "\(appState.attacks.count)",
                    systemImage: "bolt.heart"
                )

                statTile(
                    title: "Last\nattack",
                    value: lastAttackDateText,
                    systemImage: "clock"
                )
            }
        }
        .cardStyle()
    }

    private func statTile(title: String, value: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(AppTheme.primary)
                Spacer()
            }

            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .topLeading)
        .background(AppTheme.background.opacity(0.65))
        .cornerRadius(14)
    }

    private var recentAttacksSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent attacks")
                    .font(.headline)
                Spacer()
                NavigationLink {
                    AttackListView()
                } label: {
                    Text("See all")
                        .font(.caption)
                        .foregroundColor(AppTheme.primary)
                }

            }

            if appState.attacks.isEmpty {
                Text("No attacks logged yet. Tap “Log a migraine now” to start building your history.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            } else {
                VStack(spacing: 10) {
                    ForEach(recentAttacks) { attack in
                        attackRow(attack)
                    }
                }
            }
        }
        .cardStyle()
    }

    private func attackRow(_ attack: MigraineAttack) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(attack.startDate, style: .date)
                        .font(.subheadline.weight(.semibold))
                    Text(attack.startDate, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("Severity \(attack.severity)/10")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.background.opacity(0.9))
                    .foregroundColor(AppTheme.primary)
                    .cornerRadius(12)
            }

            if attack.hasAura {
                Text("Aura")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.secondary.opacity(0.25))
                    .foregroundColor(AppTheme.primary)
                    .cornerRadius(12)
            }

            // If you have linked Health context later, this will show cleanly
            if let ctx = attack.linkedContextSnapshot {
                let sleep = String(format: "%.1f", ctx.sleepHours ?? 0)
                let steps = Int(ctx.steps ?? 0)
                let hr = Int(ctx.avgHeartRateBpm ?? 0)

                Text(verbatim: "Sleep \(sleep)h • Steps \(steps) • HR \(hr)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.35))
        .cornerRadius(14)
    }
}
