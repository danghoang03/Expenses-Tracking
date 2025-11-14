//
//  Expenses_TrackingApp.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 14/11/25.
//

import SwiftUI
import SwiftData

@main
struct Expenses_TrackingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Transaction.self, Category.self, Wallet.self])
    }
}
