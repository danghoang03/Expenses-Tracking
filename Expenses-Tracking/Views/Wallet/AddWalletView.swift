//
//  AddWalletView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 16/11/25.
//

import SwiftUI
import SwiftData

struct AddWalletView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var balance: Double = 0
    @State private var selectedColor: Color = . blue
    @State private var selectedIcon: String = "creditcard.fill"
    
    @FocusState private var isAmountFocused: Bool
    
    let walletIcons = ["creditcard.fill", "banknote", "building.columns.fill", "smartphone"]
    
    var body: some View {
        NavigationStack {
            Form {
                infoSection
                appearanceSection
            }
            .navigationTitle(AppStrings.Wallet.addTitle)
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
                        saveWallet()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

extension AddWalletView {
    private var infoSection: some View {
        Section(AppStrings.Wallet.basicInfo) {
            TextField(AppStrings.Wallet.namePlaceholder, text: $name)
            
            HStack {
                Text(AppStrings.Wallet.currentBalance)
                Spacer()
                TextField("0", value: $balance, format: .currency(code: "VND"))
                    .keyboardType(.decimalPad)
                    .focused($isAmountFocused)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
    
    private var appearanceSection: some View {
        Section(AppStrings.Category.interface) {
            ColorPicker(AppStrings.Category.color, selection: $selectedColor)
            
            HStack {
                Text(AppStrings.Wallet.icon)
                Spacer()
                Picker("", selection: $selectedIcon) {
                    ForEach(walletIcons, id: \.self) { icon in
                        Image(systemName: icon).tag(icon)
                    }
                }
                .pickerStyle(.palette)
            }
        }
    }
    
    private func saveWallet() {
        let newWallet = Wallet(name: name, initialBalance: balance, iconSymbol: selectedIcon, colorHex: selectedColor.toHex())
        modelContext.insert(newWallet)
        dismiss()
    }
}

#Preview {
    AddWalletView()
        .modelContainer(PreviewContainer.shared)
}
