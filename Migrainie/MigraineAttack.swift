import Foundation

struct MigraineAttack: Identifiable, Codable {

    // MARK: - Identity
    let id: UUID

    // MARK: - Core migraine data
    var startDate: Date
    var endDate: Date?              // nil = still ongoing
    var severity: Int               // 0–10
    var hasAura: Bool

    // MARK: - Patient-reported context
    var notes: String?
    var triggers: [String]

    // MARK: - HealthKit linkage
    var linkedContextDay: Date?           // start-of-day
    var linkedContextSnapshot: DailyContext?

    // MARK: - Initializer
    init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date? = nil,
        severity: Int,
        hasAura: Bool,
        notes: String? = nil,
        triggers: [String] = [],
        linkedContextDay: Date? = nil,
        linkedContextSnapshot: DailyContext? = nil
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.severity = severity
        self.hasAura = hasAura
        self.notes = notes
        self.triggers = triggers
        self.linkedContextDay = linkedContextDay
        self.linkedContextSnapshot = linkedContextSnapshot
    }
}

//
//  MigraineAttack.swift
//  Migrainie
//
//  Created by Pourya Mazinani on 04/12/25.
//

