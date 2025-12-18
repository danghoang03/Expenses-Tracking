//
//  CategorySelectionView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 19/11/25.
//

import SwiftUI

struct CategorySelectionView: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            if let transfer = categories.first(where: { $0.type == .transfer }) {
                Section(AppStrings.Category.system) {
                    categoryRow(for: transfer)
                }
            }
            
            Section(AppStrings.Transaction.expense) {
                ForEach(categories.filter { $0.type == .expense }) { category in
                    categoryRow(for: category)
                }
            }
            
            Section(AppStrings.Transaction.income) {
                ForEach(categories.filter { $0.type == .income }) { category in
                    categoryRow(for: category)
                }
            }
        }
        .navigationTitle(AppStrings.Transaction.selectCategory)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension CategorySelectionView {
    private func categoryRow(for category: Category) -> some View {
        Button {
            selectedCategory = category
            dismiss()
        } label: {
            HStack {
                Image(systemName: category.iconSymbol)
                    .foregroundStyle(Color(hex: category.colorHex))
                    .frame(width: 32)
                
                Text(category.name)
                    .foregroundStyle(Color.primary)
                
                Spacer()
                
                if selectedCategory == category {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                }
            }
        }
    }
}

#Preview {
    let category = Category(name: "Ăn uống", iconSymbol: "fork.knife", colorHex: "#F1C40F", type: .expense)
    return CategorySelectionView(categories: [category], selectedCategory: .constant(category))
}
