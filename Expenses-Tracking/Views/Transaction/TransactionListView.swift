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
    @State private var transactionToEdit: Transaction?
    @State private var showSuccessToast = false
    @State private var showingDeleteAlert = false
    @State private var transactionToDelete: Transaction?
    
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if transactions.isEmpty {
                    emptyView
                } else if viewModel.groupTransactions(transactions).isEmpty {
                    noResultView
                } else {
                    transactionList
                }
            }
            
            addTransactionButton
                .padding(.trailing, 30)
                .padding(.bottom, 10)
        }
        .navigationTitle("Sổ giao dịch")
        .overlay(alignment: .bottom) {
            if showSuccessToast {
                successToastView
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 20)
                    .zIndex(100)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    TransactionFilterView(viewModel: viewModel)
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .symbolVariant(viewModel.activeFilter.isActive ? .fill : .none)
                        .foregroundStyle(viewModel.activeFilter.isActive ? .blue : .primary)
                }
            }
        }
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Tìm kiếm...")
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
        }
        .sheet(item: $transactionToEdit) { transaction in
            AddTransactionView(transactionToEdit: transaction)
        }
        .alert("Xóa giao dịch", isPresented: $showingDeleteAlert) {
            Button("Hủy", role: .cancel) {
                transactionToDelete = nil
            }
            Button("Xóa", role: .destructive) {
                if let transaction = transactionToDelete {
                    withAnimation {
                        viewModel.deleteTransaction(transaction, context: modelContext)
                    }
                }
            }
        } message: {
                Text("Bạn có chắc chắn muốn xóa giao dịch này không?")
        }
        .onChange(of: viewModel.activeFilter) { _, newValue in
            if newValue.isActive {
                showToast()
            }
        }
    }
}

extension TransactionListView {
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
    
    private var noResultView: some View {
        ContentUnavailableView {
            Label("Không tìm thấy kết quả", systemImage: "magnifyingglass")
        } description: {
            if viewModel.activeFilter.isActive {
                Text("Thử thay đổi hoặc xóa bộ lọc để xem thêm kết quả.")
            } else {
                Text("Không tìm thấy kết quả cho từ khóa '\(viewModel.searchText)'")
            }
        } actions: {
            if viewModel.activeFilter.isActive {
                Button("Xoá bộ lọc") {
                    withAnimation {
                        viewModel.clearFilter()
                    }
                }
            }
        }
    }
    
    private var transactionList: some View {
        List {
            ForEach(viewModel.groupTransactions(transactions), id: \.0) { date, transactionsInDay in
                Section {
                    headerView(for: date, transactions: transactionsInDay)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .disabled(true)
                    
                    daySectionContent(transactions: transactionsInDay)
                }
            }
        }
        .listStyle(.plain)
    }
    
    private func daySectionContent(transactions: [Transaction]) -> some View {
        ForEach(transactions) { transaction in
            NavigationLink {
                TransactionDetailView(transaction: transaction)
            } label: {
                TransactionRowView(transaction: transaction)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                deleteButton(for: transaction)
                updateButton(for: transaction)
            }
        }
    }
    
    private func deleteButton(for transaction: Transaction) -> some View {
        Button(role: .destructive) {
            transactionToDelete = transaction
            showingDeleteAlert = true
        } label: {
            Label("Xoá", systemImage: "trash")
        }
    }
    
    private func updateButton(for transaction: Transaction) -> some View {
        Button {
            transactionToEdit = transaction
        } label: {
            Label("Sửa", systemImage: "pencil")
        }
        .tint(.green)
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
    
    private var successToastView: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
            
            Text("Đã áp dụng bộ lọc")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color.green)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 16)
    }
    
    private func showToast() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showSuccessToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut) {
                showSuccessToast = false
            }
        }
    }
}

#Preview {
    TransactionListView()
        .modelContainer(PreviewContainer.shared)
}
