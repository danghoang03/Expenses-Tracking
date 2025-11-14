//
//  PreviewContainer.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 14/11/25.
//

import SwiftUI
import SwiftData

@MainActor
class PreviewContainer {
    
    static let shared: ModelContainer = {
        let schema = Schema([
            Wallet.self,
            Category.self,
            Transaction.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            insertSampleData(into: container.mainContext)
            return container
        } catch {
            fatalError("Failed to create PreviewContainer: \(error)")
        }
    }()
    
    static func insertSampleData(into context: ModelContext) {
        let wallet1 = Wallet(name: "Tiền mặt", initialBalance: 5_000_000, iconSymbol: "banknote", colorHex: "#2ECC71")
        let wallet2 = Wallet(name: "Techcombank", initialBalance: 20_000_000, iconSymbol: "creditcard.fill", colorHex: "#E74C3C")
        
        context.insert(wallet1)
        context.insert(wallet2)
        
        let catFood = Category(name: "Ăn uống", iconSymbol: "fork.knife", colorHex: "#F1C40F", type: .expense)
        let catSalary = Category(name: "Lương", iconSymbol: "dollarsign.circle.fill", colorHex: "#2ECC71", type: .income)
        
        context.insert(catFood)
        context.insert(catSalary)
        
        let trans1 = Transaction(amount: 50_000, createdAt: Date(), note: "Phở bò", category: catFood, wallet: wallet1)
        let trans2 = Transaction(amount: 15_000_000, createdAt: Date().addingTimeInterval(-86400), note: "Lương tháng 10", category: catSalary, wallet: wallet2)
        
        context.insert(trans1)
        context.insert(trans2)
    }
}
