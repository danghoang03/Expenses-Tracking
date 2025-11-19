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
    
    func loadData(context: ModelContext) {
        fetchWallets(context: context)
        fetchRecentTransactions(context: context)
    }
    
    private func fetchWallets(context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<Wallet>(sortBy: [SortDescriptor(\.name)])
            self.wallets = try context.fetch(descriptor)
            
            self.totalBalance = wallets.reduce(0) { $0 + $1.currentBalance }
        } catch {
            print("Error fetching wallets: \(error)")
        }
    }
    
    private func fetchRecentTransactions(context: ModelContext) {
        do {
            var descriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            descriptor.fetchLimit = 5
            
            self.recentTransactions = try context.fetch(descriptor)
        } catch {
            print("Error fetching transactions: \(error)")
        }
    }
}
