//
//  Budget.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 24/11/25.
//

import Foundation
import SwiftData

/// Represents a monthly spending limit for a specific category.
@Model
final class Budget: Hashable {
    /// The maximum amount allowed to be spent for the linked category.
    var limit: Double
    
    /// The timestamp when this budget was created.
    var createdAt: Date
    
    /// The category associated with this budget.
    /// A category can only have one active budget per month logic (though the model allows 1-1 relationship).
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
