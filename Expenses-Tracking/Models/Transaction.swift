//
//  Transaction.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 14/11/25.
//

import Foundation
import SwiftData

@Model
final class Transaction {
    var amount: Double
    var createdAt: Date
    var note: String?
    var photo: Data?
    
    var category: Category?
    var wallet: Wallet?
    
    var destinationWallet: Wallet?
    
    init(amount: Double, createdAt: Date, note: String? = nil, category: Category? = nil, wallet: Wallet? = nil, destinationWallet: Wallet? = nil) {
        self.amount = amount
        self.createdAt = createdAt
        self.note = note
        self.category = category
        self.wallet = wallet
        self.destinationWallet = destinationWallet
    }
    
    var displayTitle: String {
        if let note = note, !note.isEmpty {
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
