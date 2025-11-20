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
            .navigationTitle("Thêm Ví Mới")
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
        Section("Thông tin cơ bản") {
            TextField("Tên ví (VD: Tiền mặt)", text: $name)
            
            HStack {
                Text("Số dư")
                Spacer()
                TextField("0", value: $balance, format: .currency(code: "VND"))
                    .keyboardType(.decimalPad)
                    .focused($isAmountFocused)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
    
    private var appearanceSection: some View {
        Section("Giao diện") {
            ColorPicker("Màu đại diện", selection: $selectedColor)
            
            HStack {
                Text("Biểu tượng")
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
