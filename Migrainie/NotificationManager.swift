import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    private let center = UNUserNotificationCenter.current()
    private let dailyReminderId = "daily_migraine_reminder"
    
    // Ask the user for notification permission
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                print("🔔 Notification auth error:", error.localizedDescription)
            }
            completion(granted)
        }
    }
    
    // Schedule a daily reminder at the given time
    func scheduleDailyReminder(at date: Date) {
        // First cancel any existing one with the same id
        cancelDailyReminder()
        
        var components = Calendar.current.dateComponents([.hour, .minute], from: date)
        components.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components,
                                                    repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "Daily health check 🌿"
        content.body = "Small habits lead to big insights. Did you have any migraine symptoms today?"

        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: dailyReminderId,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error {
                print("🔔 Failed to schedule daily reminder:", error.localizedDescription)
            } else {
                print("🔔 Daily reminder scheduled at \(components.hour ?? 0):\(components.minute ?? 0)")
            }
        }
    }
    
    // Cancel the daily reminder
    func cancelDailyReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderId])
    }
}
//
//  NotificationManager.swift
//  Migrainie
//
//  Created by Pourya Mazinani on 04/12/25.
//

