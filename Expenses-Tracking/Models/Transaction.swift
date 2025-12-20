//
//  Transaction.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 14/11/25.
//

import Foundation
import SwiftData

/// Represents a single financial record in the application.
@Model
final class Transaction {
    /// The monetary value of the transaction. ALWAYS positive.
    /// The sign (positive/negative) is determined by the `Category.type` at runtime.
    var amount: Double
    
    /// The timestamp when the transaction occurred.
    var createdAt: Date
    
    /// Optional user-provided note.
    var note: String?
    
    /// Optional attachment photo data (reserved for future use).
    var photo: Data?
    
    /// The category this transaction belongs to.
    @Relationship
    var category: Category?
    
    /// The source wallet (for Expense/Transfer) or destination wallet (for Income).
    @Relationship
    var wallet: Wallet?
    
    /// The destination wallet, used ONLY if `category.type` is `.transfer`.
    @Relationship
    var destinationWallet: Wallet?
    
    init(amount: Double, createdAt: Date, note: String? = nil, category: Category? = nil, wallet: Wallet? = nil, destinationWallet: Wallet? = nil) {
        self.amount = amount
        self.createdAt = createdAt
        self.note = note
        self.category = category
        self.wallet = wallet
        self.destinationWallet = destinationWallet
    }
    
    /// Returns a displayable title for the UI.
    ///
    /// Logic: Returns the `note` if present and not empty; otherwise returns the `category.name`.
    var displayTitle: String {
        if let note = note, !note.isEmpty {
            if let firstLineOfNote = note.split(separator: "\n", maxSplits: 1).first {
                return String(firstLineOfNote)
            }
            return note
        } else if let category = category {
            return category.name
        } else {
            return "Giao dịch khác"
        }
    }
    
    var displayIcon: String {
        return category?.iconSymbol ?? "questionmark.circle"
    }
    
    var displayColor: String {
            return category?.colorHex ?? "#808080"
        }
}
