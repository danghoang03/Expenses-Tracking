//
//  DashboardViewModel.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 19/11/25.
//

import Foundation
import SwiftData
import Observation

@Observable
class DashboardViewModel {
    var recentTransactions: [Transaction] = []
    var wallets: [Wallet] = []
    var totalBalance: Double = 0
    var currentMonthIncome: Double = 0
    var currentMonthExpense: Double = 0
    
    @MainActor
    func loadData(context: ModelContext) {
        fetchWallets(context: context)
        fetchRecentTransactions(context: context)
        calculateMonthlyStats(context: context)
    }
    
    @MainActor
    private func fetchWallets(context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<Wallet>(sortBy: [SortDescriptor(\.name)])
            self.wallets = try context.fetch(descriptor)
            
            self.totalBalance = wallets.reduce(0) { $0 + $1.currentBalance }
        } catch {
            print("Error fetching wallets: \(error)")
        }
    }
    
    @MainActor
    private func fetchRecentTransactions(context: ModelContext) {
        do {
            var descriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            descriptor.fetchLimit = 5
            
            self.recentTransactions = try context.fetch(descriptor)
        } catch {
            print("Error fetching transactions: \(error)")
        }
    }
    
    @MainActor
    private func calculateMonthlyStats(context: ModelContext) {
        let startOfMonth = Date().startOfMonth
        let nextMonth = Date().startOfNextMonth
        
        let descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate<Transaction> { transaction in
                transaction.createdAt >= startOfMonth &&
                transaction.createdAt < nextMonth
            }
        )
        
        do {
            let monthTransactions = try context.fetch(descriptor)
            
            self.currentMonthIncome = monthTransactions.filter { $0.category?.type == .income }
                .reduce(0) { $0 + $1.amount }
            
            self.currentMonthExpense = monthTransactions.filter { $0.category?.type == .expense }
                .reduce(0) { $0 + $1.amount }
        } catch {
            print("Error calculating monthly stats: \(error)")
        }
    }
}
