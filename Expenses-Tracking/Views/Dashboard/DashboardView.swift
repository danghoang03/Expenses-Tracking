//
//  DashboardView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 16/11/25.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel = DashboardViewModel()
    @State private var showingAddTransaction = false
    @State private var showingAddWallet = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 24) {
                    totalBalanceSection
                    walletScrollSection
                    recentTransactionSection
                }
                .padding(.top)
                .padding(.bottom, 80)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            
            addTransactionButton
                .padding(.trailing, 30)
                .padding(.bottom, 10)
        }
        .navigationTitle("Tổng quan")
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
                .onDisappear {
                    viewModel.loadData(context: modelContext)
                }
        }
        .sheet(isPresented: $showingAddWallet) {
            AddWalletView()
                .onDisappear {
                    viewModel.loadData(context: modelContext)
                }
        }
        .onAppear {
            viewModel.loadData(context: modelContext)
        }
    }
}

extension DashboardView {
    private var totalBalanceSection: some View {
        VStack(spacing: 8) {
            Text("Tổng tài sản")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(viewModel.totalBalance.formatted(.currency(code: "VND")))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
    
    private var walletScrollSection: some View {
        VStack(alignment: .leading) {
            Text("Ví của tôi")
                .font(.headline)
                .padding(.horizontal)
                .padding(.bottom, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.wallets) { wallet in
                        WalletCardView(wallet: wallet)
                            .frame(width: 300)
                    }
                    addWalletButton
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var addWalletButton: some View {
        Button {
            showingAddWallet = true
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .frame(width: 60, height: 140)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 4)
                
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundStyle(.blue)
                    
            }
        }
    }
    

    private var recentTransactionSection: some View {
        VStack(alignment: .leading) {
            Text("Giao dịch gần đây")
                .font(.headline)
                .padding(.horizontal)
                .padding(.bottom, 4)
            
            if viewModel.recentTransactions.isEmpty {
                emptyTransactionState
            } else {
                transactionList
            }
        }
        .padding(.bottom, 20)
    }
    
    private var emptyTransactionState: some View {
        ContentUnavailableView(
            "Chưa có giao dịch",
            systemImage: "doc.text",
            description: Text("Chọn + để thêm giao dịch đầu tiên.")
        )
    }
    
    private var transactionList: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.recentTransactions) { transaction in
                TransactionRowView(transaction: transaction)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                if transaction != viewModel.recentTransactions.last {
                    Divider().padding(.leading, 70)
                }
            }
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
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
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .modelContainer(PreviewContainer.shared)
}
