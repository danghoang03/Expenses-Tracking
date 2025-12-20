//
//  TransactionType.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 14/11/25.
//

import Foundation
import SwiftUI

/// Enumeration representing the possible types of a financial transaction.
enum TransactionType: String, Codable, CaseIterable, Identifiable {
    /// Represents money coming into a wallet (e.g. Salary, Bonus).
    case income = "Income"
    /// Represents money going out of a wallet (e.g. Food, Shopping).
    case expense = "Expense"
    /// Represents moving money between two wallets.
    case transfer = "Transfer"
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
            case .income: return AppStrings.Transaction.income
            case .expense: return AppStrings.Transaction.expense
            case .transfer: return AppStrings.Transaction.transfer
        }
    }
    
    var color: Color {
        switch self {
            case .income: return .green
            case .expense: return .red
            case .transfer: return .blue
        }
    }
}
