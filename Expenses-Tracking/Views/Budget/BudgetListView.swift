//
//  BudgetListView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 24/11/25.
//

import SwiftUI
import SwiftData

/// A view that lists all active budgets and their current status.
///
/// ``BudgetListView`` visualizes the user's spending limits.
/// Each row in the list displays:
/// - The category name.
/// - The limit vs. spent amount.
/// - A progress bar that changes color based on usage (Blue -> Orange -> Red).
///
/// It uses ``BudgetViewModel`` to perform the heavy lifting of calculating totals.
struct BudgetListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var budgets: [Budget]
    @Query private var transactions: [Transaction]
    
    @State private var viewModel = BudgetViewModel()
    @State private var showingAddBudget = false
    @State private var budgetToEdit: Budget?
    
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if budgets.isEmpty {
                    emptyView
                } else {
                    budgetList
                }
            }
            .navigationTitle(AppStrings.Budget.listTitle)
            .toolbar {
                Button(AppStrings.Budget.addTitle, systemImage: "plus") {
                    showingAddBudget = true
                }
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView()
            }
            .sheet(item: $budgetToEdit, onDismiss: { recalculate() }) { budget in
                AddBudgetView(budgetToEdit: budget)
            }
            .navigationDestination(for: Budget.self) { budget in
                BudgetDetailView(budget: budget)
            }
            .onAppear { recalculate() }
            .onChange(of: transactions) { _, _ in recalculate()}
            .onChange(of: budgets) {_, _ in recalculate()}
        }
    }
}
    
extension BudgetListView {
    private var emptyView: some View {
        ContentUnavailableView {
            Label(AppStrings.Budget.noBudget,
            systemImage: "chart.bar.doc.horizontal")
        } description: {
            Text(AppStrings.Budget.noBudgetDesc)
        } actions: {
            Button(AppStrings.Budget.creatBudgetNow) { showingAddBudget = true }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private var budgetList: some View {
        ForEach(viewModel.budgetProgresses) { item in
            BudgetRowView(item: item)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    deleteButton(for: item.budget)
                    updateButton(for: item.budget)
                }
        }
    }

    private func deleteButton(for budget: Budget) -> some View {
        Button(role: .destructive) {
            withAnimation {
                modelContext.delete(budget)
            }
        } label: {
            Label(AppStrings.General.delete, systemImage: "trash")
        }
    }
    
    private func updateButton(for budget: Budget) -> some View {
        Button {
            budgetToEdit = budget
        } label: {
            Label("Sửa", systemImage: "pencil")
        }
        .tint(.green)
    }
    
    private func recalculate() {
        viewModel.calculateBudgetProgress(budgets: budgets, context: modelContext)
    }
}

#Preview {
    BudgetListView(path: .constant(NavigationPath()))
        .modelContainer(PreviewContainer.shared)
}
