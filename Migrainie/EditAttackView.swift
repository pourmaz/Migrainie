import SwiftUI

struct EditAttackView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let attack: MigraineAttack

    @State private var startDate: Date
    @State private var endDate: Date
    @State private var severity: Int
    @State private var hasAura: Bool
    @State private var notes: String
    @State private var triggersText: String

    init(attack: MigraineAttack) {
        self.attack = attack
        _startDate = State(initialValue: attack.startDate)
        _endDate = State(initialValue: attack.endDate ?? attack.startDate)
        _severity = State(initialValue: attack.severity)
        _hasAura = State(initialValue: attack.hasAura)
        _notes = State(initialValue: attack.notes ?? "")
        _triggersText = State(initialValue: attack.triggers.joined(separator: ", "))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Time") {
                    DatePicker("Start", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End", selection: $endDate, displayedComponents: [.date, .hourAndMinute])

                    if endDate < startDate {
                        Text("End time must be after start time.")
                            .foregroundColor(.red)
                    }
                }

                Section("Symptoms") {
                    Stepper("Severity: \(severity)/10", value: $severity, in: 0...10)
                    Toggle("Aura", isOn: $hasAura)
                }

                Section("Triggers") {
                    TextField("Comma-separated triggers", text: $triggersText)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 90)
                }

                Section {
                    Button(role: .destructive) {
                        appState.deleteAttack(attack)
                        dismiss()
                    } label: {
                        Text("Delete attack")
                    }
                }
            }
            .navigationTitle("Edit attack")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        guard endDate >= startDate else { return }

                        var updated = attack
                        updated.startDate = startDate
                        updated.endDate = endDate
                        updated.severity = severity
                        updated.hasAura = hasAura
                        updated.notes = notes.isEmpty ? nil : notes

                        let triggers = triggersText
                            .split(separator: ",")
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }
                        updated.triggers = triggers

                        appState.updateAttack(updated)
                        dismiss()
                    }
                    .disabled(endDate < startDate)
                }
            }
        }
    }
}
//
//  EditAttackView.swift
//  Migrainie
//
//  Created by Pourya Mazinani on 16/12/25.
//

