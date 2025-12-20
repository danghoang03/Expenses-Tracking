//
//  DashboardViewModel.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 19/11/25.
//

import Foundation
import SwiftData
import Observation

/// Manages data for the Dashboard (Home) screen.
///
/// Responsibilities include:
/// - Calculating total assets (Total Balance).
/// - Aggregating monthly income and expense statistics.
/// - Fetching the most recent transactions for quick access.
@Observable
class DashboardViewModel {
    /// List of 5 most recent transactions.
    var recentTransactions: [Transaction] = []
    /// List of all user wallets.
    var wallets: [Wallet] = []
    /// Sum of current balances of all wallets.
    var totalBalance: Double = 0
    /// Total income for the current month.
    var currentMonthIncome: Double = 0
    /// Total expense for the current month.
    var currentMonthExpense: Double = 0
    
    /// Refreshes all dashboard data.
    ///
    /// Call this method `onAppear` or when data changes to ensure the dashboard reflects the latest state.
    /// - Parameter context: The SwiftData model context.
    @MainActor
    func loadData(context: ModelContext) {
        fetchWallets(context: context)
        fetchRecentTransactions(context: context)
        calculateMonthlyStats(context: context)
    }
    
    /// Fetches all wallets and calculates the total balance.
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
    
    /// Fetches the 5 most recent transactions, sorted by date (newest first).
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
    
    /// Calculates income and expense totals for the current month.
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
