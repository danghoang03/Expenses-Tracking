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
    func calculateBudgetProgress(budgets: [Budget], transactions: [Transaction]) {
        let currentMonthStart = Date().startOfMonth
        let currentMonthEnd = Date().endOfMonth
        
        let thisMonthExpenses = transactions.filter { transaction in
            let inTimeRange = transaction.createdAt >= currentMonthStart && transaction.createdAt <= currentMonthEnd
            let isExpense = transaction.category?.type == .expense
            return inTimeRange && isExpense
        }
        
        self.budgetProgresses = budgets.map { budget in
            let spentAmount = thisMonthExpenses.filter {
                $0.category == budget.category
            }.reduce(0) { $0 + $1.amount }
            
            return BudgetProgress(budget: budget, spent: spentAmount)
        }
        .sorted{ $0.progress > $1.progress }
    }
    
    func deleteBudget(_ budget: Budget, context: ModelContext) {
        context.delete(budget)
    }
}
