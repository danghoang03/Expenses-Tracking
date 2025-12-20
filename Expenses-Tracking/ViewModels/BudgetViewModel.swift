//
//  BudgetViewModel.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 24/11/25.
//

import Foundation
import Observation
import SwiftData

/// Manages the logic for the Budget list view, including calculating progress and spending status.
@Observable
class BudgetViewModel {
    
    /// A helper struct to hold the calculated state of a single budget.
    struct BudgetProgress: Identifiable {
        let id = UUID()
        let budget: Budget
        /// The total amount spent in this budget's category for the current month.
        let spent: Double
        
        /// The progress ratio (0.0 to 1.0) indicating how much of the budget has been consumed.
        var progress: Double {
            guard budget.limit > 0 else { return 0 }
            return min(spent / budget.limit, 1.0)
        }
        
        var isOverBudget: Bool {
            spent > budget.limit
        }
    }
    
    var budgetProgresses: [BudgetProgress] = []
    
    /// Calculates the budget progress for all provided budgets based on the current month's transactions.
    ///
    /// This method fetches all transactions for the current month and aggregates the spending for each budget's category.
    ///
    /// - Parameters:
    ///   - budgets: The list of `Budget` models to process.
    ///   - context: The SwiftData context used to fetch transactions.
    @MainActor
    func calculateBudgetProgress(budgets: [Budget], context: ModelContext) {
        let currentMonthStart = Date().startOfMonth
        let currentNextMonthStart = Date().startOfNextMonth
        
        let descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate<Transaction> { transaction in
                transaction.createdAt >= currentMonthStart &&
                transaction.createdAt < currentNextMonthStart
            }
        )
        
        do {
            let monthTransactions = try context.fetch(descriptor)
            
            self.budgetProgresses = budgets.compactMap { budget in
                guard let category = budget.category else { return nil }
                
                // Sum expenses for this specific category
                let spentAmount = monthTransactions.filter { transaction in
                    transaction.category?.type == .expense &&
                    transaction.category == category
                }
                .reduce(0) { $0 + $1.amount }
                
                return BudgetProgress(budget: budget, spent: spentAmount)
            }
            .sorted { $0.progress > $1.progress }
        } catch {
            print("Error calculating budget: \(error)")
            self.budgetProgresses = []
        }
    }
    
    func deleteBudget(_ budget: Budget, context: ModelContext) {
        context.delete(budget)
    }
}
