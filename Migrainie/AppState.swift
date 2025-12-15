import Foundation
import Combine

final class AppState: ObservableObject {
    @Published var profile: UserProfile = UserProfile()
    @Published var settings: UserSettings = UserSettings()   // 👈 NEW
    
    @Published var attacks: [MigraineAttack] = []
    @Published var dailyContexts: [Date: DailyContext] = [:]

    
    func addAttack(_ attack: MigraineAttack) {
        var a = attack
        let day = Calendar.current.startOfDay(for: attack.startDate)
        
        if let ctx = dailyContexts[day] {
            a.linkedContextDay = day
            a.linkedContextSnapshot = ctx
            attacks.append(a)
        } else {
            // If context isn't loaded yet, still save the attack now.
            // We'll fill it later once context arrives.
            a.linkedContextDay = day
            attacks.append(a)
        }
    }

    func upsertContext(_ ctx: DailyContext) {
        dailyContexts[ctx.id] = ctx
        
        // Backfill any attacks logged that day without snapshot
        for i in attacks.indices {
            if attacks[i].linkedContextSnapshot == nil {
                if let day = attacks[i].linkedContextDay, day == ctx.id {
                    attacks[i].linkedContextSnapshot = ctx
                }
            }
        }
    }

    
    func clearAttacks() {
        attacks.removeAll()
    }
    
    var migraineDaysLast30: Int {
        let calendar = Calendar.current
        guard let start = calendar.date(byAdding: .day, value: -30, to: Date()) else {
            return 0
        }
        
        let days = Set(
            attacks
                .filter { $0.startDate >= start }
                .map { calendar.startOfDay(for: $0.startDate) }
        )
        return days.count
    }
}
