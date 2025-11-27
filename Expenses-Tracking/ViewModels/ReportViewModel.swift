//
//  ReportViewModel.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 25/11/25.
//

import Foundation
import SwiftData
import Observation

@Observable
class ReportViewModel {
    
    // Data for Bar Chart
    struct DailyData: Identifiable {
        let id = UUID()
        let date: Date
        let amount: Double
    }
    
    // Data for Pie Chart
    struct CategoryData: Identifiable {
        let id = UUID()
        let categoryName: String
        let colorHex: String
        let icon: String
        let amount: Double
    }
    
    var dailyExpenses: [DailyData] = []
    var categoryExpenses: [CategoryData] = []
    var totalSpent: Double = 0
    
    @MainActor
    func processData(context: ModelContext) {
        let currentWeekStart = Date().startOfWeek
        let currentNextWeekStart = Date().startOfNextWeek
        
        let descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate<Transaction> { transaction in
            transaction.createdAt >= currentWeekStart &&
            transaction.createdAt < currentNextWeekStart
        })
        
        do {
            let transactions = try context.fetch(descriptor)
            
            let expenses = transactions.filter { $0.category?.type == .expense }
            
            self.totalSpent = expenses.reduce(0) { $0 + $1.amount }
            
            // Use for Bar Chart
            let groupedByDate = Dictionary(grouping: expenses) { transaction in
                Calendar.current.startOfDay(for: transaction.createdAt)
            }
            
            self.dailyExpenses = groupedByDate.map { (date, transactions) in
                let total = transactions.reduce(0) { $0 + $1.amount }
                return DailyData(date: date, amount: total)
            }
            .sorted { $0.date < $1.date }
            
            // Use for Pie Chart
            let groupedByCategory = Dictionary(grouping: expenses) { transaction in
                transaction.category
            }
            
            self.categoryExpenses = groupedByCategory.compactMap { (category, transactions) in
                guard let category = category else { return nil }
                let total = transactions.reduce(0) { $0 + $1.amount}
                return CategoryData(
                    categoryName: category.name,
                    colorHex: category.colorHex,
                    icon: category.iconSymbol,
                    amount: total
                )
            }
            .sorted{ $0.amount > $1.amount }
            
        } catch {
            print("Error processing report data: \(error)")
        }
    }
}
