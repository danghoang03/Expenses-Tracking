//
//  Category.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 14/11/25.
//

import Foundation
import SwiftData

@Model
final class Category {
    var name: String
    var iconSymbol: String
    var colorHex: String
    var typeRawValue: String
    var createdAt: Date
    
    @Relationship(deleteRule: .nullify, inverse: \Transaction.category)
    var transactions: [Transaction]?
    
    init(name: String, iconSymbol: String, colorHex: String, type: TransactionType) {
        self.name = name
        self.iconSymbol = iconSymbol
        self.colorHex = colorHex
        self.typeRawValue = type.rawValue
        self.createdAt = Date()
    }
    
    var type: TransactionType {
        get {
            TransactionType(rawValue: typeRawValue) ?? .expense
        }
        set {
            typeRawValue = newValue.rawValue
        }
    }
}
