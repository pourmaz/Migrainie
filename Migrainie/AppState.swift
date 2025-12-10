import Foundation
import Combine

final class AppState: ObservableObject {
    @Published var profile: UserProfile = UserProfile()
    @Published var settings: UserSettings = UserSettings()   // 👈 NEW
    
    @Published var attacks: [MigraineAttack] = []
    
    func addAttack(_ attack: MigraineAttack) {
        attacks.append(attack)
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
