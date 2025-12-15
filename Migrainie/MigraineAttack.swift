import Foundation

struct MigraineAttack: Identifiable, Codable {
    let id: UUID
    var startDate: Date
    var endDate: Date?
    var severity: Int        // 0–10
    var hasAura: Bool
    var notes: String?
    var triggers: [String]
    var linkedContextDay: Date?
    var linkedContextSnapshot: DailyContext?

    
    init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date? = nil,
        severity: Int,
        hasAura: Bool,
        notes: String? = nil,
        triggers: [String] = []
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.severity = severity
        self.hasAura = hasAura
        self.notes = notes
        self.triggers = triggers
    }
}
//
//  MigraineAttack.swift
//  Migrainie
//
//  Created by Pourya Mazinani on 04/12/25.
//

