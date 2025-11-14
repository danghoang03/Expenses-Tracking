//
//  TransactionType.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 14/11/25.
//

import Foundation
import SwiftUI

enum TransactionType: String, Codable, CaseIterable, Identifiable {
    case income = "Income"
    case expense = "Expense"
    case transfer = "Transfer"
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
            case .income: return "Thu nhập"
            case .expense: return "Chi tiêu"
            case .transfer: return "Chuyển khoản"
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
