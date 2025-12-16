import SwiftUI

struct AttackListView: View {
    @EnvironmentObject var appState: AppState
    @State private var editingAttack: MigraineAttack?

    var body: some View {
        List {
            ForEach(appState.attacks.sorted(by: { $0.startDate > $1.startDate })) { attack in
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(attack.startDate, style: .date)
                            .font(.headline)

                        Text("Start: \(timeString(attack.startDate)) • End: \(attack.endDate.map(timeString) ?? "—")")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("Severity \(attack.severity)/10")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if let ctx = attack.linkedContextSnapshot {
                            Text("Sleep \(ctx.sleepHours ?? 0, specifier: "%.1f")h • Steps \(Int(ctx.steps ?? 0)) • HR \(Int(ctx.avgHeartRateBpm ?? 0))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        appState.deleteAttack(attack)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }

                    Button {
                        editingAttack = attack
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
        .navigationTitle("All attacks")
        .listStyle(.plain)
        .sheet(item: $editingAttack) { attack in
            EditAttackView(attack: attack)
                .environmentObject(appState)
        }
    }

    private func timeString(_ date: Date) -> String {
        DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
    }
}
