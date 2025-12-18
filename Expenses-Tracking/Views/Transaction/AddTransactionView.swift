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
    
    @State private var currencyViewModel = CurrencyViewModel()
    
    @State private var selectedDate: Date = Date()
    @State private var note: String = ""
    @State private var selectedWallet: Wallet?
    @State private var selectedCategory: Category?
    @State private var selectedDestinationWallet: Wallet?
    @State private var showingAlert = false
    
    @FocusState private var isAmountFocused: Bool
    
    private var isFormValid: Bool {
        if selectedCategory?.type == .transfer {
            return currencyViewModel.finalVNDAmount > 0 && selectedWallet != nil && selectedCategory != nil && selectedDestinationWallet != nil && selectedWallet != selectedDestinationWallet
        }
        return currencyViewModel.finalVNDAmount != 0 && selectedWallet != nil && selectedCategory != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                CurrencyInputSection(viewModel: currencyViewModel)
                infoSection
                categorySection
                walletSection
            }
            .navigationTitle(transactionToEdit == nil ? AppStrings.Transaction.addTitle : AppStrings.Transaction.editTitle)
            .onAppear {
                if let transaction = transactionToEdit {
                    setupUpdateView(transaction)
                } else {
                    setupDefaults()
                }
            }
            .alert(AppStrings.Transaction.insufficientFundTitle, isPresented: $showingAlert) {
                Button(AppStrings.General.ok) { }
            } message: {
                Text(AppStrings.Transaction.insufficientFundMsg)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    if isAmountFocused {
                        Spacer()
                        Button(AppStrings.General.done) {
                            isAmountFocused = false
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppStrings.General.cancel, systemImage: "xmark") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(AppStrings.General.save) {
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
    private var infoSection: some View {
        Section {
            DatePicker(AppStrings.Transaction.date, selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                .foregroundStyle(.primary)
            
            TextField(AppStrings.Transaction.notePlaceholder, text: $note)
        }
    }
    
    private var categorySection: some View {
        Section {
            if categories.isEmpty {
                ContentUnavailableView(
                    AppStrings.Transaction.noCategoryTitle,
                    systemImage: "list.bullet.rectangle.portrait",
                    description: Text(AppStrings.Transaction.noCategoryDesc)
                )
            } else {
                NavigationLink {
                    CategorySelectionView(categories: categories, selectedCategory: $selectedCategory)
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
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .contentShape(Rectangle())
                }
            }
        }
    }
    
    private var walletSection: some View {
        Section(AppStrings.Transaction.walletHeader) {
            if wallets.isEmpty {
                Text(AppStrings.Transaction.noWallet)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading) {
                    if selectedCategory?.type == .transfer {
                        Text(AppStrings.Transaction.fromWallet)
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
                            Text(AppStrings.Transaction.toWallet)
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
        currencyViewModel.foreignAmount = transaction.amount
        selectedDate = transaction.createdAt
        note = cleanNoteContent(transaction.note ?? "")
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
        
        let finalAmount = currencyViewModel.finalVNDAmount
        
        if finalAmount > wallet.currentBalance && category.type != .income {
            showingAlert = true
            return
        }
        
        var finalNote = buildFinalNote(userNote: note, categoryName: category.name)
        
        do {
            try TransactionManager.addTransaction(amount: finalAmount, date: selectedDate, note: finalNote, category: category, wallet: wallet, destinationWallet: selectedDestinationWallet, context: modelContext)
            dismiss()
        } catch {
            print("Error saving transaction: \(error)")
        }
    }
    
    private func updateTransaction(_ transaction: Transaction) {
        guard let wallet = selectedWallet, let category = selectedCategory else {
            return
        }
        
        let finalAmount = currencyViewModel.finalVNDAmount
        var availableBalance = wallet.currentBalance
        
        if let oldWallet = transaction.wallet, oldWallet == wallet {
            if let oldType = transaction.category?.type, oldType != .income {
                availableBalance += transaction.amount
            }
        }
        
        if finalAmount > availableBalance && category.type != .income {
            showingAlert = true
            return
        }
        
        TransactionManager.deleteTransaction(transaction, context: modelContext)
        
        let finalNote = buildFinalNote(userNote: note, categoryName: category.name)
        
        do {
            try TransactionManager.addTransaction(amount: finalAmount, date: selectedDate, note: finalNote, category: category, wallet: wallet, destinationWallet: selectedDestinationWallet, context: modelContext)
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
    
    private func cleanNoteContent(_ rawNote: String) -> String {
        if let range = rawNote.range(of: "\n [") {
            return String(rawNote[..<range.lowerBound])
        }
        return rawNote
    }
    
    private func buildFinalNote(userNote: String, categoryName: String) -> String {
        var baseNote = userNote.trimmingCharacters(in: .whitespacesAndNewlines)
        if baseNote.isEmpty {
            baseNote = categoryName
        }
            
        if currencyViewModel.selectedCurrency != .vnd {
            let currencyInfo = "\n [\(currencyViewModel.foreignAmount.formatted()) \(currencyViewModel.selectedCurrency.id) - Rate: \(currencyViewModel.exchangeRate.formatted())]"
            return baseNote + currencyInfo
        }
        return baseNote
    }
}

#Preview {
    AddTransactionView()
        .modelContainer(PreviewContainer.shared)
}
