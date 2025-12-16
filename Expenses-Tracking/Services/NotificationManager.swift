//
//  NotificationManager.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 16/12/25.
//

import Foundation
import UserNotifications

@MainActor
class NotificationManager: NSObject {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()
    
    override private init() {
        super.init()
        center.delegate = self
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Error request authorization: \(error.localizedDescription)")
            return false
        }
    }
    
    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
    
    func scheduleDailyReminder(at date: Date) {
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Đã đến giờ ghi chép!"
        content.body = "Bạn đã chi tiêu gì hôm nay chưa, Hãy dành 1 phút để ghi lại nhé."
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_expense_reminder",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error when scheduling daily reminder: \(error.localizedDescription)")
            } else {
                print("Scheduling daily reminder at \(components.hour ?? 0):\(components.minute ?? 0) successfully")
            }
        }
    }
    
    func cancelNotifications() {
        center.removeAllPendingNotificationRequests()
        print("Cancelled all pending notifications")
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
}
