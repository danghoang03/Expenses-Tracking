//
//  SettingsViewModel.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 16/11/25.
//

import Observation
import SwiftUI
import UserNotifications

@Observable
class SettingsViewModel {
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
    
    var isReminderEnabled: Bool {
        didSet {
            handleToggleChange()
        }
    }
    
    var reminderTime: Date {
        didSet {
            if isReminderEnabled {
                saveSettings()
                NotificationManager.shared.scheduleDailyReminder(at: reminderTime)
            }
        }
    }
    
    var showPermissionAlert: Bool = false
    
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
