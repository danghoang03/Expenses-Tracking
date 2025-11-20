//
//  TransactionManager.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 20/11/25.
//

import Foundation
import SwiftData

struct TransactionManager {
    
    enum TransactionError: Error {
        case sameWalletTransfer
        case missingDestinatioNWallet
        case insufficientFunds
    }
    
    @MainActor
    static func addTransaction(
        amount: Double,
        date: Date,
        note: String?,
        category: Category,
        wallet: Wallet,
        destinationWallet: Wallet?,
        context: ModelContext
    ) throws {
        if category.type == .transfer {
            guard let destinationWallet = destinationWallet else {
                throw TransactionError.missingDestinatioNWallet
            }
            if wallet.persistentModelID == destinationWallet.persistentModelID {
                throw TransactionError.sameWalletTransfer
            }
        }
        
        let transaction = Transaction(
            amount: amount,
            createdAt: date,
            note: note,
            category: category,
            wallet: wallet,
            destinationWallet: destinationWallet
        )
        
        switch category.type {
        case .expense:
            wallet.currentBalance -= amount
            
        case .income:
            wallet.currentBalance += amount
            
        case .transfer:
            wallet.currentBalance -= amount
            if let destinationWallet = destinationWallet {
                destinationWallet.currentBalance += amount
            }
        }
        
        context.insert(transaction)
    }
    
    @MainActor
    static func deleteTransaction(_ transaction: Transaction, context: ModelContext) {
        guard let wallet = transaction.wallet, let category = transaction.category else {
            context.delete(transaction)
            return
        }
        
        let amount = transaction.amount
        
        switch category.type {
        case .expense:
            wallet.currentBalance += amount
            
        case .income:
            wallet.currentBalance -= amount
            
        case.transfer:
            wallet.currentBalance += amount
            if let destinationWallet = transaction.destinationWallet {
                destinationWallet.currentBalance -= amount
            }
        }
        
        context.delete(transaction)
    }
}
