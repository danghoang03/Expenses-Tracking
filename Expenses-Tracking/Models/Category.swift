//
//  Category.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 14/11/25.
//

import Foundation
import SwiftData

/// Represents a classification for transactions (e.g. Food, Salary, Transportation).
///
/// Categories help users organize their financial records and are essential for reporting and budgeting.
/// Each category is linked to a specific `TransactionType` (Income, Expense, or Transfer).
@Model
final class Category: Equatable {
    /// The user-defined name of the category
    var name: String
    
    /// The SF Symbol string used to represent this category in the UI.
    var iconSymbol: String
    
    /// The Hex color string used for UI theming
    var colorHex: String
    
    /// The raw string value of the transaction type.
    /// - Note: This is stored as a String for SwiftData compatibility.
    /// Use the computed `type` property for type-safe access.
    var typeRawValue: String
    
    /// The timestamp when this category was created.
    var createdAt: Date
    
    /// The list of transactions belonging to this category.
    /// - Note: If a category is deleted, its transactions are NOT deleted (Rule: `.nullify`).
    /// They will simply have no category.
    @Relationship(deleteRule: .nullify, inverse: \Transaction.category)
    var transactions: [Transaction]?
    
    /// The budget associated with this category.
    /// - Note: If a category is deleted, the associated budget is also deleted (Rule: `.cascade`).
    @Relationship(deleteRule: .cascade, inverse: \Budget.category)
    var budget: Budget?
    
    init(name: String, iconSymbol: String, colorHex: String, type: TransactionType) {
        self.name = name
        self.iconSymbol = iconSymbol
        self.colorHex = colorHex
        self.typeRawValue = type.rawValue
        self.createdAt = Date()
    }
    
    /// A type-safe wrapper around `typeRawValue`.
    ///
    /// Get: Converts the stored string back to `TransactionType`. Defaults to `.expense` if invalid.
    /// Set: Updates `typeRawValue` with the raw string of the new type.
    var type: TransactionType {
        get {
            TransactionType(rawValue: typeRawValue) ?? .expense
        }
        set {
            typeRawValue = newValue.rawValue
        }
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.persistentModelID == rhs.persistentModelID
    }
}
