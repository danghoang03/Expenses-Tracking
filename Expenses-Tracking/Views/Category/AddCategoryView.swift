//
//  AddCategoryView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 15/11/25.
//

import SwiftUI
import SwiftData

struct AddCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedType: TransactionType = .expense
    @State private var selectedColor: Color = .red
    @State private var selectedIcon: String = "house.fill"
    
    let sampleIcons = ["house.fill", "fork.knife", "fuelpump.fill", "cart.fill", "heart.fill", "gamecontroller.fill", "book.fill", "briefcase.fill"]
    
    var body: some View {
        NavigationStack {
            Form {
                infoSection
                appearanceSection
            }
            .navigationTitle(AppStrings.Category.addTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppStrings.General.cancel, systemImage: "xmark") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(AppStrings.General.save) {
                        saveCategory()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

extension AddCategoryView {
    private var infoSection: some View {
        Section(AppStrings.Category.info) {
            TextField(AppStrings.Category.name, text: $name)
            Picker(AppStrings.Category.type, selection: $selectedType) {
                Text(AppStrings.Transaction.expense).tag(TransactionType.expense)
                Text(AppStrings.Transaction.income).tag(TransactionType.income)
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var appearanceSection: some View {
        Section(AppStrings.Category.interface) {
            ColorPicker(AppStrings.Category.color, selection: $selectedColor)
            iconSelector
        }
    }
    
    private var iconSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(sampleIcons, id: \.self) { icon in
                    Image(systemName: icon)
                        .padding()
                        .background(selectedIcon == icon ? Color.gray.opacity(0.2) : Color.clear)
                        .clipShape(Circle())
                        .onTapGesture {
                            selectedIcon = icon
                        }
                }
            }
        }
    }
    
    private func saveCategory() {
        let newCat = Category(name: name, iconSymbol: selectedIcon, colorHex: selectedColor.toHex(), type: selectedType)
        modelContext.insert(newCat)
        dismiss()
    }
}

#Preview {
    AddCategoryView()
        .modelContainer(PreviewContainer.shared)
}
