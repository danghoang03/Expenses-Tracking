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
            .navigationTitle(budgetToEdit == nil ? AppStrings.Budget.addTitle : AppStrings.Budget.editTitle)
            .onAppear {
                loadData()
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(AppStrings.General.done) { isAmountFocused = false }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppStrings.General.cancel, systemImage: "xmark") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(AppStrings.General.save) {
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
            AppStrings.Budget.noAvailableCategoriesTitle,
            systemImage: "checkmark.circle",
            description: Text(AppStrings.Budget.noAvailableCategoriesDesc)
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
                    Text(AppStrings.Transaction.category)
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
                        Text(AppStrings.Transaction.selectCategory)
                            .foregroundStyle(.secondary)
                    }
                }
                .contentShape(Rectangle())
            }
            
            HStack {
                Text(AppStrings.Budget.limit)
                Spacer()
                TextField("0", value: $amount, format: .currency(code: AppStrings.General.currencyVND))
                    .keyboardType(.decimalPad)
                    .focused($isAmountFocused)
                    .multilineTextAlignment(.trailing)
            }
        } footer: {
            Text(AppStrings.Budget.budgetNote)
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
