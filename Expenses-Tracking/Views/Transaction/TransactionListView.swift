//
//  TransactionListView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 16/11/25.
//

import SwiftUI
import SwiftData

struct TransactionListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Transaction.createdAt, order: .reverse) private var transactions: [Transaction]
    
    @State private var viewModel = TransactionListViewModel()
    @State private var showingAddTransaction = false
    
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if transactions.isEmpty {
                    emptyView
                } else {
                    transactionList
                }
            }
            
            addTransactionButton
                .padding(.trailing, 30)
                .padding(.bottom, 10)
        }
        .navigationTitle("Sổ giao dịch")
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Tìm kiếm...")
        .overlay {
            if showingEmptySearch {
                emptySearchView
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
        }
    }
}

extension TransactionListView {
    private var showingEmptySearch: Bool {
        return !transactions.isEmpty && !viewModel.searchText.isEmpty && viewModel.groupTransactions(transactions).isEmpty
    }
    
    private var emptyView: some View {
        ContentUnavailableView{
            Label("Chưa có giao dịch", systemImage: "doc.text.magnifyingglass")
        } description: {
            Text("Hãy tạo giao dịch đầu tiên của bạn ngay bây giờ.")
        } actions: {
            Button("Thêm giao dịch") {
                showingAddTransaction = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
        }
    }
    
    private var transactionList: some View {
        List {
            ForEach(viewModel.groupTransactions(transactions), id: \.0) { date, transactionsInDay in
                Section {
                    daySectionContent(transactions: transactionsInDay)
                } header: {
                    headerView(for: date, transactions: transactionsInDay)
                }
            }
        }
        .listStyle(.plain)
    }
    
    private func daySectionContent(transactions: [Transaction]) -> some View {
        ForEach(transactions) { transaction in
            NavigationLink {
                Text("Chi tiết giao dịch, View này đang trong quá trình phát triển")
            } label: {
                TransactionRowView(transaction: transaction)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                deleteButton(for: transaction)
            }
        }
    }
    
    private func deleteButton(for transaction: Transaction) -> some View {
        Button(role: .destructive) {
            withAnimation {
                viewModel.deleteTransaction(transaction, context: modelContext)
            }
        } label: {
            Label("Xoá", systemImage: "trash")
        }
    }
    
    private func headerView(for date: Date, transactions: [Transaction]) -> some View {
        HStack {
            Text(date.formatted(date: .numeric, time: .omitted))
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            let total = viewModel.calculateDailyTotal(for: transactions)
            Text("\(total > 0 ? "+" : "")\(total.formatted(.currency(code: "VND")))")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(total >= 0 ? .green : .red)
        }
        .padding(.vertical, 4)
    }
    
    private var emptySearchView: some View {
        ContentUnavailableView(
            "Không tìm thấy kết quả cho \(viewModel.searchText)",
            systemImage: "magnifyingglass",
            description: Text("Hãy thử tìm kiếm lại với từ khóa khác")
        )
    }
    
    private var addTransactionButton: some View {
        Button {
            showingAddTransaction = true
        } label: {
            Image(systemName: "plus")
                .foregroundStyle(Color.primary)
                .colorInvert()
                .frame(width: 44, height: 44)
                .background(Color.primary)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 4)
        }
    }
}

#Preview {
    TransactionListView()
        .modelContainer(PreviewContainer.shared)
}
