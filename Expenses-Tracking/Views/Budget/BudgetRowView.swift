//
//  BudgetRowView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 19/12/25.
//

import SwiftUI

struct BudgetRowView: View {
    let item: BudgetViewModel.BudgetProgress
    
    var body: some View {
        ZStack {
            NavigationLink(value: item.budget) {
                EmptyView()
            }
            .opacity(0)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label {
                        Text(item.budget.category?.name ?? "N/A")
                            .fontWeight(.semibold)
                    } icon: {
                        Image(systemName: item.budget.category?.iconSymbol ?? "circle")
                            .foregroundStyle(Color(hex: item.budget.category?.colorHex ?? "#808080"))
                    }
                    
                    Spacer()
                    
                    Text(item.budget.limit.formatted(.currency(code: AppStrings.General.currencyVND)))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(uiColor: .systemGray5))
                        
                        Capsule()
                            .fill(progressBarColor)
                            .frame(width: min(geometry.size.width * item.progress, geometry.size.width))
                    }
                }
                .frame(height: 12)
                .padding(.vertical, 4)
                
                HStack {
                    Text("Đã chi: \(item.spent.formatted(.currency(code: AppStrings.General.currencyVND)))")
                        .font(.caption)
                        .foregroundStyle(item.isOverBudget ? .red : .secondary)
                    
                    Spacer()
                    
                    Text("\(Int(item.progress * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(progressBarColor)
                }
            }
            .padding(.vertical, 8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Ngân sách cho \(item.budget.category?.name ?? AppStrings.Transaction.category)")
        .accessibilityValue(accessibilityValueString)
        .accessibilityHint(item.isOverBudget ? Text("Cảnh báo: Đã vượt quá ngân sách") : Text(""))
    }

    private var progressBarColor: Color {
        if item.isOverBudget { return .red }
        if item.progress > 0.8 { return .orange }
        return .blue
    }
    

    private var accessibilityValueString: Text {
        let spent = item.spent.formatted(.currency(code: AppStrings.General.currencyVND))
        let limit = item.budget.limit.formatted(.currency(code: AppStrings.General.currencyVND))
        let percent = Int(item.progress * 100)
        return Text("Đã chi \(spent) trên tổng \(limit). Đạt \(percent) phần trăm")
    }
}

#Preview {
    let category = Category(name: "Ăn uống", iconSymbol: "fork.knife", colorHex: "#F1C40F", type: .expense)
    let budget = Budget(limit: 5000000, category: category)
        
    let progressItem = BudgetViewModel.BudgetProgress(budget: budget, spent: 3500000)
        
    return BudgetRowView(item: progressItem)
        .padding()
}
