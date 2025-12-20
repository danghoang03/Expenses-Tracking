//
//  BudgetViewModelTests.swift
//  Expenses-TrackingTests
//
//  Created by Hoàng Minh Hải Đăng on 20/12/25.
//

import XCTest
import SwiftData
@testable import Expenses_Tracking

@MainActor
final class BudgetViewModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var viewModel: BudgetViewModel!
    
    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Transaction.self, Wallet.self, Category.self, Budget.self, configurations: config)
        context = container.mainContext
        viewModel = BudgetViewModel()
    }
    
    func testCalculateProgress_CorrectlySumsExpenses() throws {
        // 1. Arrange
        let category = Category(name: "Food", iconSymbol: "", colorHex: "", type: .expense)
        let wallet = Wallet(name: "Cash", initialBalance: 10_000_000, iconSymbol: "", colorHex: "")
        let budget = Budget(limit: 5_000_000, category: category)
        
        context.insert(category)
        context.insert(wallet)
        context.insert(budget)
        
        // Add 2 transaction to this month
        let t1 = Transaction(amount: 1_000_000, createdAt: Date(), note: "T1", category: category, wallet: wallet)
        let t2 = Transaction(amount: 500_000, createdAt: Date(), note: "T2", category: category, wallet: wallet)
        
        context.insert(t1)
        context.insert(t2)
        
        // 2. Act
        viewModel.calculateBudgetProgress(budgets: [budget], context: context)
        
        // 3. Assert
        guard let progressItem = viewModel.budgetProgresses.first else {
            XCTFail("Not found progress item")
            return
        }
        
        XCTAssertEqual(progressItem.spent, 1_500_000, "Total spending must be 1.5tr")
        XCTAssertEqual(progressItem.progress, 0.3, accuracy: 0.01, "Progress must be 30%")
        XCTAssertFalse(progressItem.isOverBudget)
    }
    
    func testCalculateProgress_IgnoresTransactionsFromOtherMonths() throws {
        // 1. Arrange
        let category = Category(name: "Food", iconSymbol: "", colorHex: "", type: .expense)
        let wallet = Wallet(name: "Cash", initialBalance: 10_000_000, iconSymbol: "", colorHex: "")
        let budget = Budget(limit: 5_000_000, category: category)
            
        context.insert(category)
        context.insert(wallet)
        context.insert(budget)
            
        // Transaction this month
        let tThisMonth = Transaction(amount: 100_000, createdAt: Date(), note: "Now", category: category, wallet: wallet)
            
        // Transaction previous month
        let lastMonthDate = Calendar.current.date(byAdding: .day, value: -31, to: Date())!
        let tLastMonth = Transaction(amount: 500_000, createdAt: lastMonthDate, note: "Old", category: category, wallet: wallet)
            
        context.insert(tThisMonth)
        context.insert(tLastMonth)
            
        // 2. Act
        viewModel.calculateBudgetProgress(budgets: [budget], context: context)
            
        // 3. Assert
        guard let progressItem = viewModel.budgetProgresses.first else { return }
            
        XCTAssertEqual(progressItem.spent, 100_000, "Only the total for the current month will be calculated.")
    }
}
