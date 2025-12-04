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
    
    var transactionToEdit: Transaction?
    
    @State private var amount: Double = 0
    @State private var selectedDate: Date = Date()
    @State private var note: String = ""
    @State private var selectedWallet: Wallet?
    @State private var selectedCategory: Category?
    @State private var selectedDestinationWallet: Wallet?
    @State private var showingAlert = false
    
    @FocusState private var isAmountFocused: Bool
    
    private var isFormValid: Bool {
        if selectedCategory?.type == .transfer {
            return amount > 0 && selectedWallet != nil && selectedCategory != nil && selectedDestinationWallet != nil && selectedWallet != selectedDestinationWallet
        }
        return amount != 0 && selectedWallet != nil && selectedCategory != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                amountSection
                infoSection
                categorySection
                walletSection
            }
            .navigationTitle(transactionToEdit == nil ? "Giao dịch mới" : "Sửa giao dịch")
            .onAppear {
                if let transaction = transactionToEdit {
                    setupUpdateView(transaction)
                } else {
                    setupDefaults()
                }
            }
            .alert("Số dư không đủ", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text("Số dư của bạn hiện không đủ, vui lòng kiểm tra lại giao dịch.")
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    if isAmountFocused {
                        Spacer()
                        Button("Xong") {
                            isAmountFocused = false
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Huỷ", systemImage: "xmark") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        if let transaction = transactionToEdit {
                            updateTransaction(transaction)
                        } else {
                            saveTransaction()
                        }
                    }
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
                .foregroundStyle(.primary)
            
            TextField("Ghi chú (VD: Ăn sáng)", text: $note)
        }
    }
    
    private var categorySection: some View {
        Section {
            if categories.isEmpty {
                ContentUnavailableView("Chưa có danh mục", systemImage: "list.bullet.rectangle.portrait", description: Text("Vui lòng tạo danh mục ở phần Cài đặt."))
            } else {
                NavigationLink {
                    CategorySelectionView(categories: categories, selectedCategory: $selectedCategory)
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
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .contentShape(Rectangle())
                }
            }
        }
    }
    
    private var walletSection: some View {
        Section("Tài khoản / Ví") {
            if wallets.isEmpty {
                Text("Chưa có ví, vui lòng tạo ví ở phần Cài đặt")
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading) {
                    if selectedCategory?.type == .transfer {
                        Text("Từ ví")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 20)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(wallets) { wallet in
                                WalletSelectionCardView(
                                    wallet: wallet,
                                    isSelected: selectedWallet == wallet,
                                    customBalance: getDisplayBalance(for: wallet)
                                )
                                    .onTapGesture {
                                        withAnimation {
                                            selectedWallet = wallet
                                        }
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 8)
                    
                    if selectedCategory?.type == .transfer {
                        Divider()
                        
                        VStack(alignment: .leading) {
                            Text("Đến ví")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(wallets.filter { $0 != selectedWallet }) { wallet in
                                        WalletSelectionCardView(
                                            wallet: wallet,
                                            isSelected: selectedDestinationWallet == wallet,
                                            customBalance: getDisplayBalance(for: wallet)
                                        )
                                            .onTapGesture {
                                                withAnimation {
                                                    selectedDestinationWallet = wallet
                                                }
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
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
    
    private func setupUpdateView(_ transaction: Transaction) {
        amount = transaction.amount
        selectedDate = transaction.createdAt
        note = transaction.note ?? ""
        selectedWallet = transaction.wallet
        selectedCategory = transaction.category
        if selectedCategory?.type == .transfer {
            selectedDestinationWallet = transaction.destinationWallet
        }
    }
    
    private func saveTransaction() {
        guard let wallet = selectedWallet, let category = selectedCategory else {
            return
        }
        
        if amount > wallet.currentBalance && category.type != .income {
            showingAlert = true
            return
        }
        
        do {
            try TransactionManager.addTransaction(amount: amount, date: selectedDate, note: note, category: category, wallet: wallet, destinationWallet: selectedDestinationWallet, context: modelContext)
            dismiss()
        } catch {
            print("Error saving transaction: \(error)")
        }
    }
    
    private func updateTransaction(_ transaction: Transaction) {
        guard let wallet = selectedWallet, let category = selectedCategory else {
            return
        }
        
        var availableBalance = wallet.currentBalance
        
        if let oldWallet = transaction.wallet, oldWallet == wallet {
            if let oldType = transaction.category?.type, oldType != .income {
                availableBalance += transaction.amount
            }
        }
        
        if amount > availableBalance && category.type != .income {
            showingAlert = true
            return
        }
        
        TransactionManager.deleteTransaction(transaction, context: modelContext)
        
        do {
            try TransactionManager.addTransaction(amount: amount, date: selectedDate, note: note, category: category, wallet: wallet, destinationWallet: selectedDestinationWallet, context: modelContext)
            dismiss()
        } catch {
            print("Error updating transaction: \(error)")
        }
    }
    
    private func getDisplayBalance(for wallet: Wallet) -> Double? {
        var balance = wallet.currentBalance
        
        guard let transaction = transactionToEdit else {
            return balance
        }
        
        if let oldWallet = transaction.wallet, oldWallet == wallet {
            if let type = transaction.category?.type {
                switch type {
                case .expense, .transfer:
                    balance += transaction.amount
                case .income:
                    balance -= transaction.amount
                }
            }
        }
        
        if let destWallet = transaction.destinationWallet,
            destWallet == wallet,
           transaction.category?.type == .transfer {
            balance -= transaction.amount
        }
        
        return balance
    }
}

#Preview {
    AddTransactionView()
        .modelContainer(PreviewContainer.shared)
}
