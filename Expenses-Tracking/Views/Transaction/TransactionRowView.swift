//
//  TransactionRowView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 19/11/25.
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    
    @ScaledMetric(relativeTo: .body) var iconSize: CGFloat = 44
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: transaction.displayIcon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: iconSize, height: iconSize)
                .background(Color(hex: transaction.displayColor))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.displayTitle)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(transaction.createdAt.formatted(date: .numeric, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(formattedAmount)
                .fontWeight(.bold)
                .foregroundStyle(amountColor)
                .layoutPriority(1)
                .minimumScaleFactor(0.8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(transaction.displayTitle), vào ngày \(transaction.createdAt.formatted(date: .numeric, time: .omitted))"))
        .accessibilityValue(Text("Số tiền \(formattedAmount)"))
        .accessibilityHint(Text("Chạm hai lần để xem chi tiết"))
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
