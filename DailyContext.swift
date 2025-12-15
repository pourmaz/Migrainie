import Foundation

struct DailyContext: Codable, Identifiable {
    // Use start-of-day as ID (stable)
    let id: Date
    
    var sleepHours: Double?
    var steps: Double?
    var distanceKm: Double?
    var activeEnergyKcal: Double?
    var avgHeartRateBpm: Double?
    
    init(day: Date,
         sleepHours: Double? = nil,
         steps: Double? = nil,
         distanceKm: Double? = nil,
         activeEnergyKcal: Double? = nil,
         avgHeartRateBpm: Double? = nil) {
        self.id = day
        self.sleepHours = sleepHours
        self.steps = steps
        self.distanceKm = distanceKm
        self.activeEnergyKcal = activeEnergyKcal
        self.avgHeartRateBpm = avgHeartRateBpm
    }
}
//
//  DailyContext.swift
//  Migrainie
//
//  Created by Pourya Mazinani on 15/12/25.
//

