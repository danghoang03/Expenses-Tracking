//
//  BudgetListView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 24/11/25.
//

import SwiftUI
import SwiftData

struct BudgetListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var budgets: [Budget]
    @Query private var transactions: [Transaction]
    
    @State private var viewModel = BudgetViewModel()
    @State private var showingAddBudget = false
    
    
    var body: some View {
        NavigationStack {
            List {
                if budgets.isEmpty {
                    emptyView
                } else {
                    budgetList
                }
            }
            .navigationTitle("Ngân sách tháng này")
            .toolbar {
                Button("Thêm ngân sách", systemImage: "plus") {
                    showingAddBudget = true
                }
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView()
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
            Label("Chưa có ngân sách",
            systemImage: "chart.bar.doc.horizontal")
        } description: {
            Text("Đặt giới hạn chi tiêu giúp bạn kiểm soát tài chính tốt hơn.")
        } actions: {
            Button("Tạo ngân sách ngay") { showingAddBudget = true }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private var budgetList: some View {
        ForEach(viewModel.budgetProgresses) { item in
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
                    
                    Text(item.budget.limit.formatted(.currency(code: "VND")))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                //Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(uiColor: .systemGray5))
                        
                        Capsule()
                            .fill(progressBarColor(for: item))
                            .frame(width: min(geometry.size.width * item.progress, geometry.size.width))
                    }
                }
                .frame(height: 12)
                .padding(.vertical)
                
                HStack {
                    Text("Đã chi: \(item.spent.formatted(.currency(code: "VND")))")
                        .font(.caption)
                        .foregroundStyle(item.isOverBudget ? .red : .secondary)
                    
                    Spacer()
                    
                    Text("\(Int(item.progress * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(progressBarColor(for: item))
                }
            }
            .padding(.vertical, 8)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                deleteButton(for: item.budget)
            }
        }
    }

    private func deleteButton(for budget: Budget) -> some View {
        Button(role: .destructive) {
            withAnimation {
                modelContext.delete(budget)
            }
        } label: {
            Label("Xoá", systemImage: "trash")
        }
    }
    
    private func progressBarColor(for item: BudgetViewModel.BudgetProgress) -> Color {
        if item.isOverBudget { return .red }
        if item.progress > 0.8 { return .orange }
        return .blue
    }
    
    private func deleteBudgets(_ offsets: IndexSet) {
        for index in offsets {
            let budget = viewModel.budgetProgresses[index].budget
            modelContext.delete(budget)
        }
    }
    
    private func recalculate() {
        viewModel.calculateBudgetProgress(budgets: budgets, context: modelContext)
    }
}

#Preview {
    BudgetListView()
        .modelContainer(PreviewContainer.shared)
}
