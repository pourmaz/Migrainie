import SwiftUI

// MARK: - Green Palette (bridged to your AppTheme)

struct GreenPalette {
    // Mapping your friend’s palette onto existing app theme
    static let lightest = AppTheme.background              // #E7F5DC
    static let light    = AppTheme.card                    // #CFE1B9
    static let midLight = Color(hex: "#B6C99B")            // extra tone
    static let mid      = AppTheme.secondary               // #98A77C
    static let midDark  = AppTheme.muted                   // #88976C
    static let darkest  = AppTheme.primary                 // #728156
}

// MARK: - Preset enums

enum StartPreset {
    case justNow
    case oneHourAgo
    case other
}

enum EndPreset {
    case stillGoing
    case justNow
    case other
}

// MARK: - Detail Screen (Select START / END)

struct AttackDetailView: View {
    let modeTitle: String      // "Select START" or "Select END"
    let presetLabel: String    // "Just now", "1h ago", "Other", ...
    let day: Int               // selected day number (1...31) in current month
    
    @Binding var selectedDate: Date
    
    @State private var time: Date
    @State private var inSleep = false
    @Environment(\.dismiss) private var dismiss
    
    init(
        modeTitle: String,
        presetLabel: String,
        day: Int,
        selectedDate: Binding<Date>
    ) {
        self.modeTitle = modeTitle
        self.presetLabel = presetLabel
        self.day = day
        self._selectedDate = selectedDate
        // initialise local time from current selected date
        _time = State(initialValue: selectedDate.wrappedValue)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [GreenPalette.lightest, GreenPalette.midLight],
                           startPoint: .top,
                           endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Custom top bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(GreenPalette.darkest)
                            .padding(10)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("1/7")
                        .foregroundColor(GreenPalette.darkest)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 20))
                            .foregroundColor(GreenPalette.darkest)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Main card
                VStack(spacing: 18) {
                    
                    Text(modeTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(GreenPalette.darkest)
                    
                    Text("Preset: \(presetLabel)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(GreenPalette.darkest.opacity(0.7))
                    
                    DatePicker("",
                               selection: $time,
                               displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                    
                    // For simplicity we show current month/year
                    let calendar = Calendar.current
                    let now = Date()
                    let comps = calendar.dateComponents([.year, .month], from: now)
                    let monthName = DateFormatter().monthSymbols[(comps.month ?? 1) - 1]
                    Text("\(monthName) \(comps.year ?? 2025)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(GreenPalette.darkest)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7),
                              spacing: 12) {
                        ForEach(1...31, id: \.self) { d in
                            Text("\(d)")
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(
                                    Capsule().fill(d == day ? GreenPalette.mid : Color.clear)
                                )
                                .foregroundColor(
                                    d == day ? .white :
                                        GreenPalette.darkest.opacity(0.8)
                                )
                        }
                    }
                    
                    Toggle("Attack \(modeTitle.lowercased()) in my sleep", isOn: $inSleep)
                        .toggleStyle(SwitchToggleStyle(tint: GreenPalette.mid))
                        .foregroundColor(GreenPalette.darkest.opacity(0.8))
                }
                .padding()
                .background(GreenPalette.light.opacity(0.6))
                .cornerRadius(24)
                .padding(.horizontal)
                .padding(.top, 16)
                
                Spacer()
                
                Button(action: confirmSelection) {
                    Text("Confirm")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(colors: [GreenPalette.mid, GreenPalette.midDark],
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .cornerRadius(20)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func confirmSelection() {
        let calendar = Calendar.current
        let now = Date()
        
        var comps = calendar.dateComponents([.year, .month], from: now)
        comps.day = day
        comps.hour = calendar.component(.hour, from: time)
        comps.minute = calendar.component(.minute, from: time)
        comps.second = 0
        
        let newDate = calendar.date(from: comps) ?? selectedDate
        selectedDate = newDate
        dismiss()
    }
}

// MARK: - Log Migraine Screen (Start/End selection)

struct LogMigraineView: View {
    
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDay = 4
    let days = Array(1...7)              // 7-day strip for quick nav
    let week = ["M", "T", "W", "T", "F", "S", "S"]
    
    @State private var startPreset: StartPreset = .justNow
    @State private var endPreset: EndPreset = .stillGoing
    
    @State private var customStartDate: Date = Date()
    @State private var customEndDate: Date = Date()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                Text(todayLabel)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(GreenPalette.darkest)
                    .padding(.top, 20)
                
                // Week row
                HStack {
                    ForEach(week.indices, id: \.self) { i in
                        Text(week[i])
                            .font(.system(size: 14,
                                          weight: i == 2 ? .bold : .regular))
                            .foregroundColor(
                                i == 2
                                ? GreenPalette.darkest
                                : GreenPalette.midDark.opacity(0.6)
                            )
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Days row (select only)
                HStack {
                    ForEach(days, id: \.self) { d in
                        Button {
                            selectedDay = d
                        } label: {
                            Text("\(d)")
                                .font(.system(size: 20, weight: .medium))
                                .frame(width: 42, height: 42)
                                .background(
                                    Circle()
                                        .fill(
                                            d == selectedDay
                                            ? GreenPalette.light
                                            : Color.white.opacity(0.2)
                                        )
                                )
                                .foregroundColor(
                                    d == selectedDay
                                    ? GreenPalette.darkest
                                    : GreenPalette.darkest.opacity(0.8)
                                )
                        }
                    }
                }
                .padding(.top, 8)
                
                Spacer()
                
                // START TIME BOX
                VStack(alignment: .leading, spacing: 16) {
                    Text("Start time:")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(GreenPalette.darkest)
                    
                    HStack(spacing: 12) {
                        Button(action: { startPreset = .justNow }) {
                            pillButtonLabel("Just now",
                                            selected: startPreset == .justNow)
                        }
                        
                        Button(action: { startPreset = .oneHourAgo }) {
                            pillButtonLabel("1h ago",
                                            selected: startPreset == .oneHourAgo)
                        }
                        
                        NavigationLink {
                            AttackDetailView(
                                modeTitle: "Select START",
                                presetLabel: "Other",
                                day: selectedDay,
                                selectedDate: $customStartDate
                            )
                        } label: {
                            pillButtonLabel("Other",
                                            selected: startPreset == .other)
                        }
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                startPreset = .other
                            }
                        )
                    }
                }
                .padding()
                .background(GreenPalette.light.opacity(0.5))
                .cornerRadius(18)
                .padding(.horizontal)
                
                // END TIME BOX
                VStack(alignment: .leading, spacing: 16) {
                    Text("End time:")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(GreenPalette.darkest)
                    
                    HStack(spacing: 12) {
                        Button(action: { endPreset = .stillGoing }) {
                            pillButtonLabel("Still going",
                                            selected: endPreset == .stillGoing)
                        }
                        
                        Button(action: { endPreset = .justNow }) {
                            pillButtonLabel("Just now",
                                            selected: endPreset == .justNow)
                        }
                        
                        NavigationLink {
                            AttackDetailView(
                                modeTitle: "Select END",
                                presetLabel: "Other",
                                day: selectedDay,
                                selectedDate: $customEndDate
                            )
                        } label: {
                            pillButtonLabel("Other",
                                            selected: endPreset == .other)
                        }
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                endPreset = .other
                            }
                        )
                    }
                }
                .padding()
                .background(GreenPalette.light.opacity(0.5))
                .cornerRadius(18)
                .padding(.horizontal)
                
                Spacer()
                
                // SAVE button – actually creates a MigraineAttack
                Button(action: saveAttack) {
                    Text("Save migraine")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(colors: [GreenPalette.mid, GreenPalette.midDark],
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .cornerRadius(20)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
            .background(
                LinearGradient(colors: [GreenPalette.lightest, GreenPalette.midLight],
                               startPoint: .top,
                               endPoint: .bottom)
                .ignoresSafeArea()
            )
        }
    }
    
    private var todayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: Date())
    }
    
    // Helper for pill-style buttons (selected vs normal)
    private func pillButtonLabel(_ text: String, selected: Bool) -> some View {
        Text(text)
            .font(.system(size: 16))
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    if selected {
                        LinearGradient(
                            colors: [GreenPalette.mid, GreenPalette.midDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        GreenPalette.light
                    }
                }
            )
            .cornerRadius(14)
            .foregroundColor(selected ? .white : GreenPalette.darkest)
    }
    
    // MARK: - Save attack into AppState
    
    private func saveAttack() {
        let now = Date()
        var startDate = now
        var endDate: Date? = nil
        
        switch startPreset {
        case .justNow:
            startDate = now
        case .oneHourAgo:
            startDate = now.addingTimeInterval(-3600)
        case .other:
            startDate = customStartDate
        }
        
        switch endPreset {
        case .stillGoing:
            endDate = nil
        case .justNow:
            endDate = now
        case .other:
            endDate = customEndDate
        }
        
        let day = Calendar.current.startOfDay(for: startDate)

        if HealthKitManager.shared.isAuthorized {
            HealthKitManager.shared.fetchDailyContext(for: day) { ctx in
                DispatchQueue.main.async {
                    appState.upsertContext(ctx)  // stores and backfills
                    var attack = MigraineAttack(
                        startDate: startDate,
                        endDate: endDate,
                        severity: 5,
                        hasAura: false,
                        notes: nil,
                        triggers: []
                    )
                    attack.linkedContextDay = day
                    attack.linkedContextSnapshot = ctx
                    appState.addAttack(attack)
                    dismiss()
                }
            }
        } else {
            // Save without context if not authorized
            let attack = MigraineAttack(
                startDate: startDate,
                endDate: endDate,
                severity: 5,
                hasAura: false,
                notes: nil,
                triggers: []
            )
            appState.addAttack(attack)
            dismiss()
        }

        }
    }

