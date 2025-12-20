//
//  TransactionListViewModel.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 22/11/25.
//

import Foundation
import SwiftData
import Observation

enum TimeFilterOption: Equatable, Hashable {
    case all
    case specificMonth(date: Date, label: String)
    
    static func == (lhs: TimeFilterOption, rhs: TimeFilterOption) -> Bool {
        switch (lhs, rhs) {
        case (.all, .all): return true
        case (.specificMonth(let d1, _), . specificMonth(let d2, _)):
            return Calendar.current.isDate(d1, equalTo: d2, toGranularity: .month)
        default: return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .all:
            hasher.combine("all")
        case .specificMonth(let date, _):
            let components = Calendar.current.dateComponents([.year, .month], from: date)
            hasher.combine(components.month)
            hasher.combine(components.year)
        }
    }
}

/// Configuration struct representing the current active filters for the transaction list.
struct TransactionFilterConfig: Equatable {
    var timeOption: TimeFilterOption = .all
    // all nil value below mean all cases
    var selectedWallet: Wallet? = nil
    var selectedType: TransactionType? = nil
    var selectedCategory: Category? = nil
    
    var isActive: Bool {
        return timeOption != .all || selectedWallet != nil || selectedType != nil || selectedCategory != nil
    }
}

/// The ViewModel responsible for managing, filtering, and searching transactions.
@Observable
class TransactionListViewModel {
    var searchText: String = ""
    
    var activeFilter: TransactionFilterConfig = TransactionFilterConfig()
    
    
    /// Generates a list of available months for the time filter.
    ///
    /// - Returns: An array of `TimeFilterOption` representing the last 12 months from the current date.
    var availableMonths: [TimeFilterOption] {
        var options: [TimeFilterOption] = []
        let calendar = Calendar.current
        let currentDate = Date()
        
        for i in 0..<12 {
            if let date = calendar.date(byAdding: .month,  value: -i, to: currentDate) {
                let month = calendar.component(.month, from: date)
                let year = calendar.component(.year, from: date)
                options.append(.specificMonth(date: date, label: "Tháng \(month)/\(year)"))
            }
        }
        return options
    }
    
    /// Groups and filters transactions for display in the list.
    ///
    /// This function applies two layers of filtering:
    /// 1. **Search Text:** Matches against the transaction note or category name (case-insensitive).
    /// 2. **Active Filters:** Applies the criteria defined in `activeFilter` (Time, Wallet, Type, Category).
    ///
    /// After filtering, it groups the transactions by day (ignoring time) for sectioned display.
    ///
    /// - Parameter transactions: The raw list of transactions fetched from SwiftData.
    /// - Returns: An array of tuples, where each tuple contains a `Date` (start of day) and the list of `Transaction`s for that day.
    func groupTransactions(_ transactions: [Transaction]) ->[(Date, [Transaction])] {
        let filteredTransaction = transactions.filter { transaction in
            let matchesSearch: Bool
            if searchText.isEmpty {
                matchesSearch = true
            } else {
                let noteMatch = transaction.note?.localizedCaseInsensitiveContains(searchText) ?? false
                let categoryMatch = transaction.category?.name.localizedCaseInsensitiveContains(searchText) ?? false
                matchesSearch = noteMatch || categoryMatch
            }
            
            let matchesFilter = applyFilter(transaction: transaction)
            
            return matchesSearch && matchesFilter
        }
        
        let groupedTransaction = Dictionary(grouping: filteredTransaction) { transaction in
            Calendar.current.startOfDay(for: transaction.createdAt)
        }
        
        return groupedTransaction.sorted { $0.key > $1.key }
    }
    
    /// Internal helper to check if a single transaction matches the active filter configuration.
    private func applyFilter(transaction: Transaction) -> Bool {
        // Check time
        if case .specificMonth(let date, _) = activeFilter.timeOption {
            if !Calendar.current.isDate(transaction.createdAt, equalTo: date, toGranularity: .month) {
                return false
            }
        }
        
        // Check Wallet
        if let filterWallet = activeFilter.selectedWallet {
            let isSource = transaction.wallet == filterWallet
            let isDest = transaction.destinationWallet == filterWallet
            if !isSource && !isDest {
                return false
            }
        }
        
        // Check type
        if let filterType = activeFilter.selectedType {
            if transaction.category?.type != filterType {
                return false
            }
        }
        
        // Check Category
        if let filterCategory = activeFilter.selectedCategory {
            if transaction.category != filterCategory {
                return false
            }
        }
        
        return true
    }
    
    /// Calculates the net total amount for a specific list of transactions.
    ///
    /// Logic:
    /// - **Income:** Adds to the total.
    /// - **Expense:** Subtracts from the total.
    /// - **Transfer:** Ignored (returns the current result unchanged), as it doesn't affect the net daily cash flow in this context.
    ///
    /// - Parameter transactions: The list of transactions to calculate.
    /// - Returns: The calculated net total.
    func calculateDailyTotal(for transactions: [Transaction]) -> Double {
        transactions.reduce(0) { result, transaction in
            let amount = transaction.amount
            
            guard let type = transaction.category?.type else { return result }
            
            switch type {
            case .expense:
                return result - amount
            case .income:
                return result + amount
            case .transfer:
                return result // Transfer don't affect total daily
            }
        }
    }
    
    func deleteTransaction(_ transaction: Transaction, context: ModelContext) {
        TransactionManager.deleteTransaction(transaction, context: context)
    }
    
    func clearFilter() {
        activeFilter = TransactionFilterConfig()
    }
}
