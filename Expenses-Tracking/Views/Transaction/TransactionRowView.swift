//
//  TransactionRowView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 19/11/25.
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.displayIcon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color(hex: transaction.displayColor))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.displayTitle)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(transaction.createdAt.formatted(date: .numeric, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(formattedAmount)
                .fontWeight(.bold)
                .foregroundStyle(amountColor)
        }
    }
}

extension TransactionRowView {
    private var formattedAmount: String {
        let prefix = (transaction.category?.type == .income) ? "+" : (transaction.category?.type == .expense ? "-" : "")
        return "\(prefix)\(transaction.amount.formatted(.currency(code: AppStrings.General.currencyVND)))"
    }
    
    private var amountColor: Color {
        guard let type = transaction.category?.type else { return .primary }
        switch type {
        case .income: return .green
        case .expense: return .red
        case .transfer: return .blue
        }
    }
}

#Preview {
    TransactionRowView(transaction: Transaction(amount: 50_000, createdAt: Date(), note: "Phở bò", category: nil, wallet: nil))
        .padding()
}
