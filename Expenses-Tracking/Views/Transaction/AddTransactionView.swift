//
//  AddTransactionView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 19/11/25.
//

import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Wallet.name) private var wallets: [Wallet]
    @Query(sort: \Category.name) private var categories: [Category]
    
    @State private var amount: Double = 0
    @State private var selectedDate: Date = Date()
    @State private var note: String = ""
    @State private var selectedWallet: Wallet?
    @State private var selectedCategory: Category?
    
    @FocusState private var isAmountFocused: Bool
    
    private var isFormValid: Bool {
        amount == 0 && selectedWallet != nil && selectedCategory != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                amountSection
                infoSection
                categorySection
                walletSection
            }
            .navigationTitle("Giao dịch mới")
            .onTapGesture { isAmountFocused = false }
            .onAppear(perform: setupDefaults)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Huỷ", systemImage: "xmark") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") { saveTransaction() }
                        .disabled(!isFormValid)
                }
            }
        }
    }
}

extension AddTransactionView {
    private var amountSection: some View {
        Section {
            HStack {
                Text(selectedCategory?.type == .income ? "+" : "-")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(selectedCategory?.type == .income ? .green : .red)
                
                TextField("0", value: $amount, format: .currency(code: "VND"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .keyboardType(.decimalPad)
                    .focused($isAmountFocused)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.vertical, 8)
        }
    }
    
    private var infoSection: some View {
        Section {
            DatePicker("Ngày giao dịch", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
            
            TextField("Ghi chú (VD: Ăn sáng)", text: $note)
        }
    }
    
    private var categorySection: some View {
        Section("Danh mục") {
            if categories.isEmpty {
                ContentUnavailableView("Chưa có danh mục", systemImage: "list.bullet.rectangle.portrait", description: Text("Vui lòng tạo danh mục trước."))
            } else {
                Picker("Chọn danh mục", selection: $selectedCategory) {
                    ForEach(categories) { category in
                        HStack {
                            Image(systemName: category.iconSymbol)
                            Text(category.name)
                        }
                        .tag(category as Category?)
                    }
                }
                .pickerStyle(.navigationLink)
            }
        }
    }
    
    private var walletSection: some View {
        Section("Tài khoản / Ví") {
            if wallets.isEmpty {
                Text("Vui lòng tạo ví trước")
                    .foregroundStyle(.red)
            } else {
                Picker("Chọn ví", selection: $selectedWallet) {
                    ForEach(wallets) { wallet in
                        HStack {
                            Image(systemName: wallet.iconSymbol)
                            Text(wallet.name)
                            Spacer()
                            Text(wallet.currentBalance.formatted(.currency(code:  "VND")))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .tag(wallet as Wallet?)
                    }
                }
                .pickerStyle(.navigationLink)
            }
        }
    }
    
    private func setupDefaults() {
        if selectedWallet == nil {
            selectedWallet = wallets.first
        }
        
        if selectedCategory == nil {
            selectedCategory = categories.first
        }
    }
    
    private func saveTransaction() {
        guard let wallet = selectedWallet, let category = selectedCategory else {
            return
        }
        
        let newTransaction = Transaction(
            amount: amount,
            createdAt: selectedDate,
            note: note.isEmpty ? nil : note,
            category: category,
            wallet: wallet
        )
        
        switch category.type {
        case.expense:
            wallet.currentBalance -= amount
        case .income:
            wallet.currentBalance += amount
        case .transfer:
            break
        }
        
        modelContext.insert(newTransaction)
        dismiss()
    }
}

#Preview {
    AddTransactionView()
        .modelContainer(PreviewContainer.shared)
}
