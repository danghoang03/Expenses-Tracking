//
//  SettingsViewModel.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 16/11/25.
//

import Observation
import SwiftUI
import UserNotifications

/// Manages user preferences and application settings.
@Observable
class SettingsViewModel {
    /// Enumeration defining the navigation destinations within Settings.
    enum Route: Hashable, CaseIterable {
        case wallets
        case categories
        
        var title: String {
            switch self {
            case .wallets: "Quản lý Ví"
            case .categories: "Quản lý Danh mục"
            }
        }
        
        var icon: String {
            switch self {
            case .wallets: "creditcard.fill"
            case .categories: "list.bullet.rectangle.portrait.fill"
            }
        }
    }
    
    var menuItems: [Route] = Route.allCases
    
    /// Toggle state for daily reminders.
    /// Changing this value triggers `handleToggleChange()`.
    var isReminderEnabled: Bool {
        didSet {
            handleToggleChange()
        }
    }
    
    /// The time set for the daily reminder.
    /// Updates are saved immediately and the notification is rescheduled.
    var reminderTime: Date {
        didSet {
            if isReminderEnabled {
                saveSettings()
                NotificationManager.shared.scheduleDailyReminder(at: reminderTime)
            }
        }
    }
    
    var showPermissionAlert: Bool = false
    
    /// Initializes the ViewModel by loading preferences from UserDefaults.
    init() {
        self.isReminderEnabled = UserDefaults.standard.bool(forKey: "isReminderEnabled")
        if let savedDate = UserDefaults.standard.object(forKey: "reminderTime") as? Date {
            self.reminderTime = savedDate
        } else {
            var components = DateComponents()
            components.hour = 20
            components.minute = 0
            self.reminderTime = Calendar.current.date(from: components) ?? Date()
        }
    }
    
    /// Handles the logic when the reminder toggle is switched.
    ///
    /// - If Enabled: Requests notification permission. If granted, schedules the reminder. If denied, shows alert.
    /// - If Disabled: Cancels all pending notifications.
    private func handleToggleChange() {
        saveSettings()
        
        if isReminderEnabled {
            Task {
                let granted = await NotificationManager.shared.requestAuthorization()
                
                if granted {
                    NotificationManager.shared.scheduleDailyReminder(at: reminderTime)
                } else {
                    self.isReminderEnabled = false
                    self.showPermissionAlert = true
                }
            }
        } else {
            NotificationManager.shared.cancelNotifications()
        }
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(isReminderEnabled, forKey: "isReminderEnabled")
        UserDefaults.standard.set(reminderTime, forKey: "reminderTime")
    }
    
    func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
