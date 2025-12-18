//
//  TransactionFilterView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 08/12/25.
//

import SwiftUI
import SwiftData

struct TransactionFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: TransactionListViewModel
    
    @State private var draftFilter: TransactionFilterConfig
    @State private var isTimeExpanded: Bool = false
    
    @Query(sort: \Wallet.name) private var wallets: [Wallet]
    @Query(sort: \Category.name) private var categories: [Category]
    
    init(viewModel: TransactionListViewModel) {
        self.viewModel = viewModel
        _draftFilter = State(initialValue: viewModel.activeFilter)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                timeSection
                walletSection
                typeSection
                
                if draftFilter.selectedType != nil && draftFilter.selectedType != .transfer {
                    categorySection
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding()
            .padding(.bottom, 90)
        }
        .navigationTitle("Bộ lọc")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            bottomActionButtons
        }
        .toolbar(.hidden, for: .tabBar)
        .animation(.default, value: draftFilter.selectedType)
    }
}

extension TransactionFilterView {
    private var timeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AppStrings.Transaction.byTime)
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                filterButton(
                    title: AppStrings.Transaction.all,
                    isSelected: draftFilter.timeOption == .all
                ) {
                    draftFilter.timeOption = .all
                }
                
                let monthsToShow = isTimeExpanded ? viewModel.availableMonths : Array(viewModel.availableMonths.prefix(5))
                
                ForEach(monthsToShow, id: \.self) { option in
                    if case .specificMonth(_, let label) = option {
                        filterButton(
                            title: label,
                            isSelected: draftFilter.timeOption == option
                        ) {
                            draftFilter.timeOption = option
                        }
                    }
                }
            }
            
            Button {
                withAnimation {
                    isTimeExpanded.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Text(isTimeExpanded ? AppStrings.Transaction.reduce : AppStrings.Transaction.expand)
                        .font(.footnote)
                        .fontWeight(.medium)

                    Image(systemName: isTimeExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .padding(.top, 4)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var walletSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AppStrings.Transaction.byWallet)
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                filterButton(
                    title: AppStrings.Transaction.all,
                    isSelected: draftFilter.selectedWallet == nil
                ) {
                    draftFilter.selectedWallet = nil
                }
                
                ForEach(wallets) { wallet in
                    filterButton(
                        title: wallet.name,
                        isSelected: draftFilter.selectedWallet == wallet
                    ) {
                        draftFilter.selectedWallet = wallet
                    }
                }
            }
        }
    }
    
    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AppStrings.Transaction.byType)
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                filterButton(
                    title: AppStrings.Transaction.all,
                    isSelected: draftFilter.selectedType == nil
                ) {
                    draftFilter.selectedType = nil
                }
                
                ForEach(TransactionType.allCases) { type in
                    filterButton(
                        title: type.title,
                        isSelected: draftFilter.selectedType == type
                    ) {
                        withAnimation {
                            draftFilter.selectedType = type
                            if type != .transfer {
                                draftFilter.selectedCategory = nil
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AppStrings.Transaction.byCategory)
                .font(.headline)
            
            let filteredCategories = categories.filter { $0.type == draftFilter.selectedType }
            
            if filteredCategories.isEmpty {
                Text(AppStrings.Transaction.noCategoryTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
                    filterButton(
                        title: AppStrings.Transaction.all,
                        isSelected: draftFilter.selectedCategory == nil
                    ) {
                        draftFilter.selectedCategory = nil
                    }
                    
                    ForEach(filteredCategories) { category in
                        filterButton(
                            title: category.name,
                            isSelected: draftFilter.selectedCategory == category
                        ) {
                            draftFilter.selectedCategory = category
                        }
                    }
                }
            }
        }
    }
    
    private var bottomActionButtons: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 16) {
                Button {
                    viewModel.clearFilter()
                    dismiss()
                } label: {
                    Text(AppStrings.Transaction.deleteFilter)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                }
                
                Button {
                    viewModel.activeFilter = draftFilter
                    dismiss()
                } label: {
                    Text(AppStrings.Transaction.apply)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
        }
    }
    
    private func filterButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14))
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .padding(.horizontal, 4)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.blue.opacity(0.1) : Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        TransactionFilterView(viewModel: TransactionListViewModel())
    }
    .modelContainer(PreviewContainer.shared)
}
