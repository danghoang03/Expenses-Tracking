//
//  BudgetCategorySelectionView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 24/11/25.
//

import SwiftUI

struct BudgetCategorySelectionView: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List(categories) { category in
            Button {
                selectedCategory = category
                dismiss()
            } label: {
                HStack {
                    Image(systemName: category.iconSymbol)
                        .foregroundStyle(Color(hex: category.colorHex))
                        .frame(width: 32)
                    
                    Text(category.name)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    if selectedCategory == category {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                            .fontWeight(.bold)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .navigationTitle("Chọn danh mục")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let category = Category(name: "Ăn uống", iconSymbol: "fork.knife", colorHex: "#F1C40F", type: .expense)
    return BudgetCategorySelectionView(categories: [category], selectedCategory: .constant(category))
}
