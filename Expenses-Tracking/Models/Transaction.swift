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
    
    init(amount: Double, createdAt: Date, note: String? = nil, category: Category? = nil, wallet: Wallet? = nil) {
        self.amount = amount
        self.createdAt = createdAt
        self.note = note
        self.category = category
        self.wallet = wallet
    }
}
