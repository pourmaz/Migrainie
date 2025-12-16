import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        headerCard

                        if appState.attacks.isEmpty {
                            emptyStateCard
                        } else {
                            sevenDayChartCard
                            thirtyDayChartCard
                            topTriggersCard
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Insights")
        }
    }

    // MARK: - Data model for charts

    struct DayPoint: Identifiable {
        let id = UUID()
        let day: Date           // start of day
        let migraineDayCount: Int  // 0 or 1 (or could be >1 if you prefer)
    }

    private func dayPoints(lastDays n: Int) -> [DayPoint] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        // Build a set of migraine days from attacks
        let migraineDays: Set<Date> = Set(
            appState.attacks.map { cal.startOfDay(for: $0.startDate) }
        )

        // Create points for each day in range (oldest → newest)
        return (0..<n).reversed().map { offset in
            let day = cal.date(byAdding: .day, value: -offset, to: today) ?? today
            let isMigraineDay = migraineDays.contains(day)
            return DayPoint(day: day, migraineDayCount: isMigraineDay ? 1 : 0)
        }
    }

    // MARK: - Cards

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your migraine patterns")
                .font(.title3.bold())

            Text("These charts show how often you logged migraines per day. Use them to spot clusters and improvement trends.")
                .font(.callout)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .cardStyle()
    }

    private var emptyStateCard: some View {
        VStack(spacing: 10) {
            Text("No data yet")
                .font(.title2.bold())
            Text("Log your first migraine from Home. Once you have logs, charts will appear here.")
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .cardStyle()
    }

    private var sevenDayChartCard: some View {
        let points = dayPoints(lastDays: 7)

        return VStack(alignment: .leading, spacing: 10) {
            Text("Last 7 days")
                .font(.headline)

            Chart(points) { p in
                BarMark(
                    x: .value("Day", p.day),
                    y: .value("Migraine day", p.migraineDayCount)
                )
                .cornerRadius(4)
            }
            .chartYScale(domain: 0...1)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    if let intVal = value.as(Int.self), intVal == 0 || intVal == 1 {
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 1)) { value in
                    AxisGridLine().foregroundStyle(.clear)
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .frame(height: 180)

            Text("A bar means you had at least one migraine logged that day.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .cardStyle()
    }

    private var thirtyDayChartCard: some View {
        let points = dayPoints(lastDays: 30)

        return VStack(alignment: .leading, spacing: 10) {
            Text("Last 30 days")
                .font(.headline)

            Chart(points) { p in
                LineMark(
                    x: .value("Day", p.day),
                    y: .value("Migraine day", p.migraineDayCount)
                )
                PointMark(
                    x: .value("Day", p.day),
                    y: .value("Migraine day", p.migraineDayCount)
                )
            }
            .chartYScale(domain: 0...1)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    if let intVal = value.as(Int.self), intVal == 0 || intVal == 1 {
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 5)) { value in
                    AxisGridLine().foregroundStyle(.clear)
                    AxisValueLabel(format: .dateTime.day())
                }
            }
            .frame(height: 180)

            Text("Line view helps you see clusters across the month.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .cardStyle()
    }

    private var topTriggersCard: some View {
        // Simple count of how often each trigger appears
        let counts = Dictionary(grouping: appState.attacks.flatMap { $0.triggers }) { $0 }
            .mapValues { $0.count }
        let topTriggers = counts.sorted { $0.value > $1.value }.prefix(3)

        return VStack(alignment: .leading, spacing: 8) {
            Text("Top triggers")
                .font(.headline)

            if topTriggers.isEmpty {
                Text("You haven’t added triggers yet. When logging, select likely triggers to build insights.")
                    .font(.callout)
                    .foregroundColor(.secondary)
            } else {
                ForEach(Array(topTriggers), id: \.key) { trigger, count in
                    HStack {
                        Text(trigger)
                        Spacer()
                        Text("\(count)x")
                            .foregroundColor(AppTheme.primary)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .cardStyle()
    }
}
