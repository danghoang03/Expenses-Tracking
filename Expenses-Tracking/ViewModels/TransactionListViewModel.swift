//
//  TransactionListViewModel.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 22/11/25.
//

import Foundation
import SwiftData
import Observation

@Observable
class TransactionListViewModel {
    var searchText: String = ""
    
    func groupTransactions(_ transactions: [Transaction]) ->[(Date, [Transaction])] {
        let filteredTransaction = transactions.filter { transaction in
            if searchText.isEmpty { return true }
            
            let noteMatch = transaction.note?.localizedStandardContains(searchText) ?? false
            let categoryMatch = transaction.category?.name.localizedStandardContains(searchText) ?? false
            
            return noteMatch || categoryMatch
        }
        
        let groupedTransaction = Dictionary(grouping: filteredTransaction) { transaction in
            Calendar.current.startOfDay(for: transaction.createdAt)
        }
        
        return groupedTransaction.sorted { $0.key > $1.key }
    }
    
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
}
