//
//  AddBudgetView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 24/11/25.
//

import SwiftUI
import SwiftData

struct AddBudgetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(filter: #Predicate<Category> { $0.typeRawValue == "Expense"}, sort: \Category.name) private var categories: [Category]
    
    @State private var amount: Double = 0
    @State private var selectedCategory: Category?
    @FocusState private var isAmountFocused: Bool
    
    private var availableCategories: [Category] {
        categories.filter { $0.budget == nil }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if availableCategories.isEmpty {
                    emptyView
                } else {
                    inputView
                }
            }
            .navigationTitle("Tạo ngân sách")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Xong") { isAmountFocused = false }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Huỷ", systemImage: "xmark") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") { saveBudget() }
                        .disabled(amount <= 0 ||  selectedCategory == nil)
                }
            }
        }
    }
}

extension AddBudgetView {
    private var emptyView: some View {
        ContentUnavailableView(
            "Không còn danh mục khả dụng",
            systemImage: "checkmark.circle",
            description: Text("Tất cả danh mục chi tiêu đều đã có ngân sách.")
        )
    }
    
    private var inputView: some View {
        Section {
            NavigationLink {
                BudgetCategorySelectionView(
                    categories: availableCategories,
                    selectedCategory: $selectedCategory
                )
            } label: {
                HStack {
                    Text("Danh mục")
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    if let category = selectedCategory {
                        HStack {
                            Image(systemName: category.iconSymbol)
                                .foregroundStyle(Color(hex: category.colorHex))
                            Text(category.name)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("Chọn danh mục")
                            .foregroundStyle(.secondary)
                    }
                }
                .contentShape(Rectangle())
            }
            
            HStack {
                Text("Hạn mức")
                Spacer()
                TextField("0", value: $amount, format: .currency(code: "VND"))
                    .keyboardType(.decimalPad)
                    .focused($isAmountFocused)
                    .multilineTextAlignment(.trailing)
            }
        } footer: {
            Text("Ngân sách sẽ áp dụng cho tháng hiện tại và được tính toán dựa trên các giao dịch chi tiêu.")
        }
    }
    
    private func saveBudget() {
        guard let category = selectedCategory else { return }
        let newBudget = Budget(limit: amount, category: category)
        modelContext.insert(newBudget)
        dismiss()
    }
}

#Preview {
    AddBudgetView()
        .modelContainer(PreviewContainer.shared)
}
