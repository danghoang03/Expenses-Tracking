//
//  BudgetViewModel.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 24/11/25.
//

import Foundation
import Observation
import SwiftData

@Observable
class BudgetViewModel {
    
    struct BudgetProgress: Identifiable {
        let id = UUID()
        let budget: Budget
        let spent: Double
        
        var progress: Double {
            guard budget.limit > 0 else { return 0 }
            return min(spent / budget.limit, 1.0)
        }
        
        var isOverBudget: Bool {
            spent > budget.limit
        }
    }
    
    var budgetProgresses: [BudgetProgress] = []
    
    // calculate budget progresses base on transactions of current month
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
