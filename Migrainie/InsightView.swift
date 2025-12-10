import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 18) {
                        if appState.attacks.isEmpty {
                            emptyCard
                        } else {
                            frequencyCard
                            triggerCard
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Insights")
        }
    }
    
    private var emptyCard: some View {
        VStack(spacing: 10) {
            Text("No data yet")
                .font(.title2.bold())
            Text("Once you log a few migraine attacks, Migrainie will start showing patterns here.")
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .cardStyle()
    }
    
    private var frequencyCard: some View {
        let total = appState.attacks.count
        let days30 = appState.migraineDaysLast30
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Frequency")
                .font(.headline)
            Text("Migraine days (last 30 days): \(days30)")
                .font(.title3.bold())
            Text("Total attacks logged: \(total)")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .cardStyle()
    }
    
    private var triggerCard: some View {
        // Simple count of how often each trigger appears
        let counts = Dictionary(grouping: appState.attacks.flatMap { $0.triggers }) { $0 }
            .mapValues { $0.count }
        let topTriggers = counts.sorted { $0.value > $1.value }.prefix(3)
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Top triggers")
                .font(.headline)
            
            if topTriggers.isEmpty {
                Text("You haven’t added any triggers yet. Next time you log a migraine, try selecting a few likely triggers.")
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
//
//  InsightView.swift
//  Migrainie
//
//  Created by Pourya Mazinani on 04/12/25.
//

