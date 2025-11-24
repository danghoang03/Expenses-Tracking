//
//  Budget.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 24/11/25.
//

import Foundation
import SwiftData

@Model
final class Budget {
    var limit: Double
    var createdAt: Date
    
    var category: Category?
    
    init(limit: Double, category: Category) {
        self.limit = limit
        self.category = category
        self.createdAt = Date()
    }
}
