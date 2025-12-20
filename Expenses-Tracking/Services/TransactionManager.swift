//
//  TransactionManager.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 20/11/25.
//

import Foundation
import SwiftData

/// A centralized manager for handling transaction in lifecycle events.
///
/// The `TransactionManager` is responsible for creating , updating and deleting transactions.
/// Crucially, it manages the side effects of these actions, such as updating the `currentBalance`
/// of the associated `Wallet` (and `destinationWallet` for transfers).
///
///  - Note: All methods in this struct must be called from the Main Actor context as they modify SwiftData models directly.

struct TransactionManager {
    
    /// Errors that can occur during transaction operations
    enum TransactionError: Error {
        /// Thrown when a transfer is attempted between the same wallet instance.
        case sameWalletTransfer
        /// Thrown when a transfer type transaction is missing a destination wallet.
        case missingDestinationWallet
        /// Thrown when the wallet does not have enough funds (optional validation).
        case insufficientFunds
    }
    
    /// Creates a new transaction and updates the associated wallet balances.
    ///
    ///  This method performs the following actions:
    ///  1. Validates the transfer logic (if category type is `.transfer`).
    ///  2. Creates a `Transaction` object.
    ///  3. Updates the `currentBalance` of the source `wallet`.
    ///  4. If applicable, updates the `currentBalance` of the `destinationWallet`.
    ///  5. Inserts the transaction into the provider `ModelContext`.
    ///
    /// - Parameters:
    ///   - amount: The monetary value of the transaction.
    ///   - date: The date and time when the transaction occurred.
    ///   - note: An optional text note describing the transaction.
    ///   - category: The `Category` associated with the transaction. Determines if it's income, expense, or transfer.
    ///   - wallet: The source `Wallet` where the money is taken from (expense/transfer) or added to (income).
    ///   - destinationWallet: The target `Wallet` for transfer transactions. Required if category type is `.transfer`.
    ///   - context: The SwiftData `ModelContext` used to persist changes.
    ///
    /// - Throws: `TransactionError.missingDestinationWallet` if type is transfer but no destination is provided.
    /// - Throws: `TransactionError.sameWalletTransfer` if source and destination wallets are the same.
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
                throw TransactionError.missingDestinationWallet
            }
            if wallet == destinationWallet {
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
    
    /// Deletes an existing transaction and reverts the wallet balance changes.
    ///
    /// When a transaction is deleted, this method reverses the financial impact on the wallets:
    /// - **Expense:** The amount is added back to the wallet.
    /// - **Income:** The amount is deducted from the wallet.
    /// - **Transfer:** The amount is added back to the source wallet and deducted from the destination wallet.
    ///
    /// - Parameters:
    ///    - transaction: The `Transaction` object to delete.
    ///    - context: The SwiftData `ModelContext` used to perform the deletion.
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
    
    /// Updates an existing transaction and adjusts wallet balances accordingly.
    ///
    /// This is a complex operation that handles:
    /// 1. Reverting the effect of the *old* transaction data on the *old* wallets.
    /// 2. Applying the effect of the *new* transaction data on the *new* wallets.
    /// 3. Updating the properties of the `Transaction` object.
    ///
    /// - Parameters:
    ///   - transaction: The existing `Transaction` object to modify.
    ///   - newAmount: The new monetary value.
    ///   - newDate: The new date.
    ///   - newNote: The new note.
    ///   - newCategory: The new category.
    ///   - newWallet: The new source wallet.
    ///   - newDestinationWallet: The new destination wallet (if applicable).
    ///   - context: The SwiftData `ModelContext`.
    ///
    /// - Throws: `TransactionError` if the new data violates validation rules (e.g. invalid transfer).
    @MainActor
    static func updateTransaction(
        transaction: Transaction,
        newAmount: Double,
        newDate: Date,
        newNote: String?,
        newCategory: Category,
        newWallet: Wallet,
        newDestinationWallet: Wallet?,
        context: ModelContext
    ) throws {
        // Validation: Ensure transfer creates a valid link between two difference wallets
        if newCategory.type == .transfer {
            guard let destinationWallet = newDestinationWallet else {
                throw TransactionError.missingDestinationWallet
            }
            if newWallet == destinationWallet {
                throw TransactionError.sameWalletTransfer
            }
        }
        
        // MARK: - Step 1: Revert old state
        // Critical: Before applying changes, we must "undo" the financial impact of the original transaction
        // to return the wallets to their state as if the transaction never happened.
        if let oldWallet = transaction.wallet, let oldCategory = transaction.category {
            let oldAmount = transaction.amount
            
            switch oldCategory.type {
            case .expense:
                oldWallet.currentBalance += oldAmount // Revert expense: Add money back
            case .income:
                oldWallet.currentBalance -= oldAmount // Revert income: Remove money
            case .transfer:
                oldWallet.currentBalance += oldAmount // Revert transfer source: Add money back
                if let oldDestinationWwallet = transaction.destinationWallet {
                    oldDestinationWwallet.currentBalance -= oldAmount // Revert transfer dest: Remove money
                }
            }
        }
        
        // MARK: - Step 2: Update model properties
        // Apply the new properties to the SwiftData object
        transaction.amount = newAmount
        transaction.createdAt = newDate
        transaction.note = newNote
        transaction.category = newCategory
        transaction.wallet = newWallet
        transaction.destinationWallet = newDestinationWallet
        
        // MARK: - Step 3: Apply new state
        // Calculate the new balances based on the updated transaction details
        switch newCategory.type {
        case .expense:
            newWallet.currentBalance -= newAmount
        case .income:
            newWallet.currentBalance += newAmount
        case .transfer:
            newWallet.currentBalance -= newAmount
            if let newDestinationWallet = newDestinationWallet {
                newDestinationWallet.currentBalance += newAmount
            }
        }
    }
}
