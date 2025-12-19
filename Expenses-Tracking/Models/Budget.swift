//
//  Budget.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 24/11/25.
//

import Foundation
import SwiftData

@Model
final class Budget: Hashable {
    var limit: Double
    var createdAt: Date
    
    var category: Category?
    
    init(limit: Double, category: Category) {
        self.limit = limit
        self.category = category
        self.createdAt = Date()
    }
    
    static func == (lhs: Budget, rhs: Budget) -> Bool {
        return lhs === rhs 
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
