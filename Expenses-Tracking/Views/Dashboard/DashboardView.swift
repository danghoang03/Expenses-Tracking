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
                    overviewSection
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
        .navigationTitle(AppStrings.Dashboard.title)
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
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(AppStrings.Dashboard.totalBalance)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))

                    Text(viewModel.totalBalance.formatted(.currency(code: AppStrings.General.currencyVND)))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer()

                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(10)
                    .background(.white.opacity(0.16), in: Circle())
            }

            HStack(spacing: 12) {
                overviewMetric(
                    title: AppStrings.Dashboard.monthlyIncome,
                    value: viewModel.currentMonthIncome,
                    systemImage: "arrow.down.left",
                    tint: .green
                )

                overviewMetric(
                    title: AppStrings.Dashboard.monthlyExpense,
                    value: viewModel.currentMonthExpense,
                    systemImage: "arrow.up.right",
                    tint: .red
                )
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    colors: [
                        Color(uiColor: .systemBlue),
                        Color(uiColor: .systemIndigo)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 10)
        }
        .padding(.horizontal)
        .padding(.top)
    }

    private func overviewMetric(title: String, value: Double, systemImage: String, tint: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.callout.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(.white.opacity(0.2), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))

                Text(value.formatted(.currency(code: AppStrings.General.currencyVND)))
                    .font(.system(size: 13))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.white.opacity(0.14), lineWidth: 1)
        }
    }

    
    private var walletScrollSection: some View {
        VStack(alignment: .leading) {
            Text(AppStrings.Dashboard.myWallets)
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
            Text(AppStrings.Dashboard.recentTransactions)
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
            AppStrings.Dashboard.noTransactionTitle,
            systemImage: "doc.text",
            description: Text(AppStrings.Dashboard.noTransactionDesc)
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
        Button() {
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
