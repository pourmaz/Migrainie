import Foundation

struct UserSettings: Codable {
    var dailyReminderEnabled: Bool = false
    var dailyReminderTime: Date = {
        // default 9:00 in the morning today
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 9
        comps.minute = 0
        return Calendar.current.date(from: comps) ?? Date()
    }()
    
    var askAuraByDefault: Bool = true
    var showTriggersStep: Bool = true
}
//
//  UserSettings.swift
//  Migrainie
//
//  Created by Pourya Mazinani on 04/12/25.
//

