//
//  LogMigraineFlowView.swift
//  Migrainie
//
//  Created by Pourya Mazinani on 16/12/25.
//
import SwiftUI

struct LogMigraineFlowView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var healthKit: HealthKitManager

    @State private var step: Int = 1
    @State private var draft = MigraineDraft()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [GreenPalette.lightest, GreenPalette.midLight],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                ScrollView(showsIndicators: false) {
                    Group {
                        switch step {
                        case 1: StepTime(draft: $draft)
                        case 2: StepSeverity(draft: $draft)
                        case 3: StepLocation(draft: $draft)
                        case 4: StepSymptoms(draft: $draft)
                        case 5: StepTriggers(draft: $draft)
                        case 6: StepReview(draft: $draft)
                        default: StepInsights(draft: draft)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 90) // ✅ keeps content above bottomBar
                }

                bottomBar
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var topBar: some View {
        HStack {
            Button {
                if step == 1 { dismiss() }
                else { step -= 1 }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(GreenPalette.darkest)
                    .padding(10)
                    .background(Color.white.opacity(0.85))
                    .clipShape(Circle())
            }

            Spacer()

            Text("\(step)/7")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(GreenPalette.darkest.opacity(0.9))

            Spacer()

            Image(systemName: "questionmark.circle")
                .font(.system(size: 20))
                .foregroundColor(GreenPalette.darkest.opacity(0.9))
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            Button {
                if step == 1 { dismiss() }
                else { step -= 1 }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 56, height: 56)
                    .background(GreenPalette.light.opacity(0.9))
                    .foregroundColor(GreenPalette.darkest)
                    .cornerRadius(18)
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                if step < 7 {
                    step += 1
                } else {
                    saveAndDismiss()
                }
            } label: {
                Image(systemName: step < 7 ? "chevron.right" : "checkmark")
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 56, height: 56)
                    .background(GreenPalette.mid)
                    .foregroundColor(.white)
                    .cornerRadius(18)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 18)
        .padding(.top, 10)
        .background(GreenPalette.lightest.opacity(0.95))
    }

    // MARK: - Save into your existing app model (+ HealthKit context)

    private func saveAndDismiss() {
        // Ensure end state consistent
        if draft.endPreset == .stillGoing {
            draft.endDate = nil
        }

        let attackStart = draft.startDate
        let day = Calendar.current.startOfDay(for: attackStart)

        // Map triggers to your existing model (array of Strings)
        let triggerStrings = draft.triggers.map { $0.title }.sorted()
        let symptomStrings = draft.symptoms.map { $0.title }.sorted()

        let locationString = draft.painLocation?.title ?? "Not selected"
        let notes = """
        Location: \(locationString)
        Symptoms: \(symptomStrings.isEmpty ? "None" : symptomStrings.joined(separator: ", "))
        """


        func commitAttack(with ctx: DailyContext?) {
            var attack = MigraineAttack(
                startDate: draft.startDate,
                endDate: draft.endDate,
                severity: draft.severity,
                hasAura: false,
                notes: notes,
                triggers: triggerStrings
            )
            let day = Calendar.current.startOfDay(for: draft.startDate)
            attack.linkedContextDay = day
            
            if let ctx {
                attack.linkedContextDay = day
                attack.linkedContextSnapshot = ctx
                appState.upsertContext(ctx)
            } else {
                attack.linkedContextDay = day
            }

            appState.addAttack(attack)
            dismiss()
        }

        // If Health is connected, fetch context for that day; otherwise save immediately
        if healthKit.isAuthorized {
            HealthKitManager.shared.fetchDailyContext(for: day) { ctx in
                DispatchQueue.main.async {
                    commitAttack(with: ctx)
                }
            }
        } else {
            commitAttack(with: nil)
        }
    }
}
// MARK: - Step 1: Time (functional Date/Time)

struct StepTime: View {
    @Binding var draft: MigraineDraft

    var body: some View {
        VStack(spacing: 16) {
            Text("When did it start?")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(GreenPalette.darkest)

            VStack(alignment: .leading, spacing: 12) {
                Text("Start")
                    .font(.headline)
                    .foregroundColor(GreenPalette.darkest)

                DatePicker(
                    "Start",
                    selection: $draft.startDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                
                .datePickerStyle(.compact)
                .labelsHidden()
            }
            .padding()
            .background(GreenPalette.light.opacity(0.6))
            .cornerRadius(18)
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 12) {
                Text("End")
                    .font(.headline)
                    .foregroundColor(GreenPalette.darkest)

                Toggle("Still going", isOn: Binding(
                    get: { draft.endDate == nil },
                    set: { isOn in
                        if isOn { draft.endDate = nil }
                        else { draft.endDate = max(draft.startDate, Date()) }
                    }
                ))
                .toggleStyle(SwitchToggleStyle(tint: GreenPalette.mid))

                if draft.endDate != nil {
                    DatePicker(
                        "End",
                        selection: Binding(
                            get: { draft.endDate ?? Date() },
                            set: { newVal in draft.endDate = newVal }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                }
            }
            .padding()
            .background(GreenPalette.light.opacity(0.6))
            .cornerRadius(18)
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 20)
    }
}

// MARK: - Step 2: Severity

struct StepSeverity: View {
    @Binding var draft: MigraineDraft

    var body: some View {
        VStack(spacing: 16) {
            Text("How strong was the pain?")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(GreenPalette.darkest)

            Text("\(draft.severity)/10")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(GreenPalette.darkest)

            Slider(value: Binding(
                get: { Double(draft.severity) },
                set: { draft.severity = Int($0.rounded()) }
            ), in: 0...10, step: 1)
            .tint(GreenPalette.mid)
            .padding(.horizontal)

            severityHint
                .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 20)
    }

    private var severityHint: some View {
        let text: String
        switch draft.severity {
        case 0...2: text = "Mild — noticeable but manageable."
        case 3...6: text = "Moderate — affects activities."
        default: text = "Severe — hard to function."
        }
        return Text(text)
            .font(.callout)
            .foregroundColor(GreenPalette.darkest.opacity(0.75))
            .multilineTextAlignment(.center)
    }
}

// MARK: - Step 3: Location (simple, keeps your draft compatible)

struct StepLocation: View {
    @Binding var draft: MigraineDraft
    private let locations = PainLocation.allCases

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 16) {
            Text("Where did it hurt most?")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(GreenPalette.darkest)

            Text("Optional")
                .font(.callout)
                .foregroundColor(GreenPalette.darkest.opacity(0.7))

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(locations) { loc in
                    LocationTile(
                        loc: loc,
                        isSelected: draft.painLocation == loc
                    ) {
                        draft.painLocation = loc
                    }
                }
            }
            .padding(.horizontal)

            Spacer(minLength: 0)
        }
        .padding(.top, 20)
    }
}

private struct LocationTile: View {
    let loc: PainLocation
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: loc.icon)
                    .foregroundColor(isSelected ? .white : GreenPalette.mid)

                Text(loc.title)
                    .foregroundColor(isSelected ? .white : GreenPalette.darkest)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(background)
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }

    private var background: some View {
        Group {
            if isSelected {
                LinearGradient(
                    colors: [GreenPalette.mid, GreenPalette.midDark],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            } else {
                GreenPalette.light.opacity(0.6)
            }
        }
    }
}



// MARK: - Step 4: Symptoms (optional placeholder – keeps flow working)

struct StepSymptoms: View {
    @Binding var draft: MigraineDraft

    // Use your enum directly
    private let symptoms = Symptom.allCases

    var body: some View {
        VStack(spacing: 16) {
            Text("Symptoms")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(GreenPalette.darkest)

            Text("Select any that apply")
                .font(.callout)
                .foregroundColor(GreenPalette.darkest.opacity(0.7))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(symptoms) { symptom in
                    Toggle(isOn: bindingForSymptom(symptom)) {
                        HStack(spacing: 10) {
                            Image(systemName: symptom.icon)
                                .foregroundColor(GreenPalette.mid)
                            Text(symptom.title)
                                .foregroundColor(GreenPalette.darkest)
                        }
                    }
                    .toggleStyle(.button)
                    .tint(GreenPalette.mid)
                    .padding()
                    .background(GreenPalette.light.opacity(0.6))
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 20)
    }

    private func bindingForSymptom(_ symptom: Symptom) -> Binding<Bool> {
        Binding(
            get: { draft.symptoms.contains(symptom) },
            set: { isOn in
                if isOn { draft.symptoms.insert(symptom) }
                else { draft.symptoms.remove(symptom) }
            }
        )
    }
}


// MARK: - Step 5: Triggers with icons (works well for demo)

struct StepTriggers: View {
    @Binding var draft: MigraineDraft

    private let triggers = Trigger.allCases

    var body: some View {
        VStack(spacing: 16) {
            Text("Triggers")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(GreenPalette.darkest)

            Text("What might have triggered it?")
                .font(.callout)
                .foregroundColor(GreenPalette.darkest.opacity(0.7))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(triggers) { trigger in
                    Toggle(isOn: bindingForTrigger(trigger)) {
                        HStack(spacing: 10) {
                            Image(systemName: trigger.icon)
                                .foregroundColor(GreenPalette.mid)
                            Text(trigger.title)
                                .foregroundColor(GreenPalette.darkest)
                        }
                    }
                    .toggleStyle(.button)
                    .tint(GreenPalette.mid)
                    .padding()
                    .background(GreenPalette.light.opacity(0.6))
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 20)
    }

    private func bindingForTrigger(_ trigger: Trigger) -> Binding<Bool> {
        Binding(
            get: { draft.triggers.contains(trigger) },
            set: { isOn in
                if isOn { draft.triggers.insert(trigger) }
                else { draft.triggers.remove(trigger) }
            }
        )
    }
}


// MARK: - Step 6: Review

struct StepReview: View {
    @Binding var draft: MigraineDraft

    var body: some View {
        VStack(spacing: 16) {
            Text("Review")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(GreenPalette.darkest)

            VStack(alignment: .leading, spacing: 10) {
                row("Start", dateTimeString(draft.startDate))
                row("End", draft.endDate == nil ? "Still going" : dateTimeString(draft.endDate!))
                row("Severity", "\(draft.severity)/10")

                row(
                    "Triggers",
                    draft.triggers.isEmpty
                    ? "None"
                    : draft.triggers.map { $0.title }.sorted().joined(separator: ", ")
                )

                row(
                    "Symptoms",
                    draft.symptoms.isEmpty
                    ? "None"
                    : draft.symptoms.map { $0.title }.sorted().joined(separator: ", ")
                )
            }

            .padding()
            .background(GreenPalette.light.opacity(0.6))
            .cornerRadius(18)
            .padding(.horizontal)

            Text("Tap ✓ to save.")
                .font(.callout)
                .foregroundColor(GreenPalette.darkest.opacity(0.7))

            Spacer()
        }
        .padding(.top, 20)
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundColor(GreenPalette.darkest.opacity(0.7))
                .frame(width: 70, alignment: .leading)
            Text(value)
                .foregroundColor(GreenPalette.darkest)
            Spacer()
        }
        .font(.callout)
    }

    private func dateTimeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}

// MARK: - Step 7: Insights placeholder

struct StepInsights: View {
    let draft: MigraineDraft

    var body: some View {
        VStack(spacing: 16) {
            Text("Saved")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(GreenPalette.darkest)

            Text("Great — your migraine has been added to your history.")
                .font(.callout)
                .foregroundColor(GreenPalette.darkest.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 20)
    }
}

