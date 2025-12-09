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
    
    var budgetToEdit: Budget?
    
    @State private var amount: Double = 0
    @State private var selectedCategory: Category?
    @State private var isDataLoaded = false
    @FocusState private var isAmountFocused: Bool
    
    private var availableCategories: [Category] {
        categories.filter {
            $0.budget == nil || (budgetToEdit != nil && $0 == budgetToEdit?.category)
        }
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
            .navigationTitle(budgetToEdit == nil ? "Tạo ngân sách" : "Sửa ngân sách")
            .onAppear {
                loadData()
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Xong") { isAmountFocused = false }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Huỷ", systemImage: "xmark") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        if let budget = budgetToEdit {
                            updateBudget(budget)
                        } else {
                            saveBudget()
                        }
                    }
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
    
    private func updateBudget(_ budget: Budget) {
        budget.limit = amount
        
        if let newCategory = selectedCategory, budget.category != newCategory{
            budget.category = newCategory
        }
        
        dismiss()
    }
    
    private func loadData() {
        guard !isDataLoaded else { return }
        
        if let budget = budgetToEdit {
            amount = budget.limit
            selectedCategory = budget.category
        }
        
        isDataLoaded = true
    }
}

#Preview {
    AddBudgetView()
        .modelContainer(PreviewContainer.shared)
}
