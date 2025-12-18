//
//  WalletListView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 16/11/25.
//

import SwiftUI
import SwiftData

struct WalletListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Wallet.name) private var wallets: [Wallet]
    
    @State private var showingAddSheet = false
    
    var body: some View {
        List {
            if wallets.isEmpty {
                emptyState
            } else {
                walletListSection
            }
        }
        .listStyle(.plain)
        .navigationTitle(AppStrings.Wallet.listTitle)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showingAddSheet = true }) {
                    Label(AppStrings.Wallet.addTitle, systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddWalletView()
        }
    }
}

extension WalletListView {
    private var emptyState: some View {
        ContentUnavailableView(
            AppStrings.Wallet.noWalletTitle,
            systemImage: "creditcard",
            description: Text(AppStrings.Wallet.noWalletDesc))
        .listRowSeparator(.hidden)
    }
    
    private var walletListSection: some View {
        ForEach(wallets) { wallet in
            WalletCardView(wallet: wallet)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .contextMenu {
                    Button(role: .destructive) {
                        deleteWallets(wallet)
                    } label: {
                        Label(AppStrings.Wallet.delete, systemImage: "trash")
                    }
                }
        }
    }
    
    private func deleteWallets(_ wallet: Wallet) {
        withAnimation {
            modelContext.delete(wallet)
        }
    }
}

#Preview {
    NavigationStack {
        WalletListView()
    }
    .modelContainer(PreviewContainer.shared)
}
