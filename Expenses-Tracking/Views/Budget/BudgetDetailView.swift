//
//  BudgetDetailView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 15/12/25.
//

import SwiftUI
import SwiftData

struct BudgetDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let budget: Budget
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        List {
            overviewSection
            
            if adviceAmount > 0 {
                adviceSection
            }
            transactionHistorySection
            
            deleteSection
        }
        .navigationTitle(budget.category?.name ?? AppStrings.Budget.detailBudget)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(AppStrings.General.edit) {
                showingEditSheet = true
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddBudgetView(budgetToEdit: budget)
        }
        .alert(AppStrings.Budget.deleteBudgetAlertTitle, isPresented: $showingDeleteAlert) {
            Button(AppStrings.General.cancel, role: .cancel) { }
            Button(AppStrings.General.delete, role: .destructive) {
                deleteBudget()
            }
        } message: {
            Text(AppStrings.Budget.deleteBudgetAlertMsg)
        }
    }
}

extension BudgetDetailView {
    private var relevantTransaction: [Transaction] {
        guard let category = budget.category else { return [] }
        
        let start = Date().startOfMonth
        let end = Date().startOfNextWeek
        
        return (category.transactions ?? [])
            .filter {
                $0.createdAt >= start &&
                $0.createdAt < end &&
                $0.category?.type == .expense
            }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    private var spentAmount: Double {
        relevantTransaction.reduce(0) { $0 + $1.amount }
    }
    
    private var remainingAmount: Double {
        budget.limit - spentAmount
    }
    
    private var progress: Double {
        guard budget.limit > 0 else { return 0 }
        return min(spentAmount / budget.limit, 1.0)
    }
    
    private var daysLeftInMonth: Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: Date())!
        let totalsDay = range.count
        let currentDay = calendar.component(.day, from: Date())
        return max(totalsDay - currentDay, 1)
    }
    
    private var adviceAmount: Double {
        return max(remainingAmount / Double(daysLeftInMonth), 0)
    }
    
    private var statusColor: Color {
        if spentAmount > budget.limit { return .red }
        if progress > 0.8 { return .orange }
        return .green
    }
    
    private var overviewSection: some View {
        Section {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color(uiColor: .systemGray5), lineWidth: 20)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            statusColor,
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring, value: progress)
                    
                    VStack {
                        Text(Int(progress * 100).formatted(.percent))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(statusColor)
                        
                        Text(AppStrings.Budget.used)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 160, height: 160)
                
                HStack(spacing: 12) {
                    infoItem(title: AppStrings.Budget.limit, value: budget.limit, color: .primary)
                    infoItem(title: AppStrings.Budget.spent, value: spentAmount, color: statusColor)
                    infoItem(title: AppStrings.Budget.remaining, value: remainingAmount, color: remainingAmount < 0 ? .red : .blue)
                }
                .padding(.top)
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
        }
        .listRowBackground(Color.clear)
    }
    
    private var adviceSection: some View {
        Section {
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppStrings.Budget.suggestion)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    
                    Text("Bạn có thể tiêu \(adviceAmount.formatted(.currency(code: AppStrings.General.currencyVND)))/ngày trong \(daysLeftInMonth) ngày tới.")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
    }
    
    private var transactionHistorySection: some View {
        Section(AppStrings.Budget.relevantTransactionsThisMonth) {
            if relevantTransaction.isEmpty {
                ContentUnavailableView(
                    AppStrings.Dashboard.noTransactionTitle,
                    systemImage: "cart",
                    description: Text(AppStrings.Transaction.noTransactionDesc)
                )
            } else {
                ForEach(relevantTransaction) { transaction in
                        TransactionRowView(transaction: transaction)
                }
            }
        }
    }
    
    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label(AppStrings.Budget.deleteBudgetAlertTitle, systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func infoItem(title: String, value: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(shortFormat(value))
                .font(.callout)
                .fontWeight(.bold)
                .foregroundStyle(color)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func shortFormat(_ value: Double) -> String {
        if abs(value) >= 1_000_000 {
            return String(format: "%.1fM", value / 1_000_000).replacingOccurrences(of: ".0", with: "")
        } else if abs(value) >= 1_000 {
            return String(format: "%.0fK", value / 1_000)
        } else {
            return value.formatted(.number)
        }
    }
    
    private func deleteBudget() {
        modelContext.delete(budget)
        dismiss()
    }
}

#Preview {
    let category = Category(name: "Ăn uống", iconSymbol: "fork.knife", colorHex: "#F1C40F", type: .expense)
    let budget = Budget(limit: 5000000, category: category)
    
    return NavigationStack {
        BudgetDetailView(budget: budget)
    }
    .modelContainer(PreviewContainer.shared)
}
