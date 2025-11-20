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
    let container: ModelContainer
    init() {
        do {
            let schema = Schema([Transaction.self, Category.self, Wallet.self])
            container = try ModelContainer(for: schema)
            checkAndSeedData(context: container.mainContext)
        } catch {
            fatalError("Failed to configure SwiftData container.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
    
    @MainActor
    private func checkAndSeedData(context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<Category>(
                predicate: #Predicate<Category> { $0.typeRawValue == "Transfer" }
            )
            let count = try context.fetchCount(descriptor)
                
            if count == 0 {
                let transferCategory = Category(
                    name: "Chuyển khoản",
                    iconSymbol: "arrow.left.arrow.right",
                    colorHex: "#3498DB", // Màu xanh dương
                    type: .transfer
                )
                context.insert(transferCategory)
                print("Seeded 'Transfer' category.")
            }
        } catch {
            print("Error seeding data: \(error)")
        }
    }
}
