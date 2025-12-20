//
//  Wallet.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 14/11/25.
//

import Foundation
import SwiftData

/// Represents a user's financial account (e.g. Cash, Bank Account, Credit Card).
@Model
final class Wallet: Equatable {
    /// The user-defined name of the wallet.
    var name: String
    
    /// The balance set when the wallet was created. Used for reference or resetting.
    var initialBalance: Double
    
    /// The real-time balance calculated by applying transactions.
    /// This value is updated by `TransactionManager`.
    var currentBalance: Double
    
    /// SF Symbol string for the wallet icon.
    var iconSymbol: String
    
    /// Hex string representing the wallet's theme color.
    var colorHex: String
    
    /// The timestamp when the wallet was created.
    var createdAt: Date
    
    /// The list of transactions associated with this wallet.
    /// - Note: When the wallet is deleted, all associated transactions are also deleted (Cascade rule).
    @Relationship(deleteRule: .cascade, inverse: \Transaction.wallet)
    var transactions: [Transaction]?
    
    init(name: String, initialBalance: Double, iconSymbol: String, colorHex: String) {
        self.name = name
        self.initialBalance = initialBalance
        self.currentBalance = initialBalance
        self.iconSymbol = iconSymbol
        self.colorHex = colorHex
        self.createdAt = Date()
    }
    
    static func == (lhs: Wallet, rhs: Wallet) -> Bool {
        return lhs.persistentModelID == rhs.persistentModelID
    }
}
