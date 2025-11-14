//
//  Wallet.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 14/11/25.
//

import Foundation
import SwiftData

@Model
final class Wallet {
    var name: String
    var initialBalance: Double
    var currentBalance: Double
    var iconSymbol: String
    var colorHex: String
    var createdAt: Date
    
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
}
