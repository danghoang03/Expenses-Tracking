//
//  TransactionDetailView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 13/12/25.
//

import SwiftUI
import SwiftData

struct TransactionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let transaction: Transaction
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        List {
            headerSection
            timeSection
            moneyFlowSection
            
            if let note = transaction.note, !note.isEmpty {
                noteSection(note)
            }
            
            deleteSection
        }
        .navigationTitle("Chi tiết giao dịch")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Sửa") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddTransactionView(transactionToEdit: transaction)
        }
        .alert("Xoá giao dịch", isPresented: $showingDeleteAlert) {
            Button("Huỷ", role: .cancel) { }
            Button("Xoá", role: .destructive) {
                deleteTransaction()
            }
        } message: {
            Text("Bạn có chắc chắn muốn xoá giao dịch này không?")
        }
    }
}

extension TransactionDetailView {
    private var headerSection: some View {
        Section {
            VStack(spacing: 8) {
                if let icon = transaction.category?.iconSymbol,
                   let colorHex = transaction.category?.colorHex {
                    Image(systemName: icon)
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                        .frame(width: 80, height: 80)
                        .background(Color(hex: colorHex))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                
                Text(transaction.category?.name ?? "Không có danh mục")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text(formatAmount())
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(amountColor)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .listRowBackground(Color.clear)
    }
    
    private var amountColor: Color {
        guard let type = transaction.category?.type else { return .primary }
        switch type {
        case .income: return .green
        case .expense: return .red
        case .transfer: return .blue
        }
    }
        
    private func formatAmount() -> String {
        let prefix = (transaction.category?.type == .income) ? "+" : (transaction.category?.type == .expense ? "-" : "")
        return "\(prefix)\(transaction.amount.formatted(.currency(code: "VND")))"
    }
    
    private var timeSection: some View {
        Section("Thời gian") {
            HStack {
                Label("Ngày", systemImage: "calendar")
                Spacer()
                Text(transaction.createdAt.formatted(date: .numeric, time: .omitted))
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Label("Giờ", systemImage: "clock")
                Spacer()
                Text(transaction.createdAt.formatted(date: .omitted, time: .shortened))
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var moneyFlowSection: some View {
        Section("Dòng tiền") {
            HStack {
                Label("Loại", systemImage: "tag")
                Spacer()
                if let type = transaction.category?.type {
                    Text(type.title)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(type.color.opacity(0.1))
                        .foregroundStyle(type.color)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            
            if let wallet = transaction.wallet {
                HStack {
                    Label(transaction.category?.type == .income ? "Vào ví" : "Từ ví", systemImage: wallet.iconSymbol)
                    Spacer()
                    Text(wallet.name)
                        .foregroundStyle(.secondary)
                }
            }
            
            if transaction.category?.type == .transfer,
                let destinationWallet = transaction.destinationWallet {
                HStack {
                    Label("Đến ví", systemImage: destinationWallet.iconSymbol)
                    Spacer()
                    Text(destinationWallet.name)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private func noteSection(_ note: String) -> some View {
        Section("Ghi chú") {
            Text(note)
                .font(.body)
                .foregroundStyle(.primary)
                .padding(.vertical, 4)
        }
    }
    
    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Xoá giao dịch", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func deleteTransaction() {
        TransactionManager.deleteTransaction(transaction, context: modelContext)
        dismiss()
    }
}

#Preview {
    let transaction = Transaction(
        amount: 150000,
        createdAt: Date(),
        note: "Ăn Buffet",
        category: Category(name: "Ăn uống", iconSymbol: "fork.knife", colorHex: "#F1C40F", type: .expense),
        wallet: Wallet(name: "Tiền mặt", initialBalance: 5000000, iconSymbol: "banknote", colorHex: "#2ECC71")
    )
        
    return NavigationStack {
        TransactionDetailView(transaction: transaction)
    }
}
