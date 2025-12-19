//
//  WalletCardView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 16/11/25.
//

import SwiftUI

struct WalletCardView: View {
    let wallet: Wallet
    
    @ScaledMetric(relativeTo: .title) var iconSize: CGFloat = 80
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            backgroundLayer
            decorativeLayer
            contentLayer
        }
        .frame(minHeight: 140)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Ví \(wallet.name)"))
        .accessibilityValue(Text("Số dư hiện tại \(wallet.currentBalance.formatted(.currency(code: AppStrings.General.currencyVND)))"))        
    }
}

extension WalletCardView {
    private var backgroundLayer: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(gradientFill)
            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 4)
    }
    
    private var gradientFill: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: wallet.colorHex),
                Color(hex: wallet.colorHex).opacity(0.7)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var decorativeLayer: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: wallet.iconSymbol)
                    .font(.system(size: iconSize))
                    .foregroundStyle(.white.opacity(0.15))
                    .offset(x: 10, y: -10)
                    .rotationEffect(.degrees(-15))
            }
            Spacer()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var contentLayer: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerView
            Spacer(minLength: 12)
            balanceView
        }
        .foregroundStyle(.white)
        .padding(16)
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: wallet.iconSymbol)
                .font(.headline)
                .padding(8)
                .background(.ultraThinMaterial.opacity(0.3))
                .clipShape(Circle())
            
            Text(wallet.name)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
            
            Spacer()
        }
    }
    
    private var balanceView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(AppStrings.Wallet.currentBalance)
                .font(.caption)
                .opacity(0.8)
            
            Text(wallet.currentBalance.formatted(.currency(code: "VND")))
                .font(.title2)
                .fontWeight(.bold)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    VStack {
        WalletCardView(wallet: Wallet(name: "Tiền mặt", initialBalance: 5_000_000, iconSymbol: "banknote", colorHex: "#2ECC71"))
            .frame(width: 300)
        
        WalletCardView(wallet: Wallet(name: "Techcombank", initialBalance: 25_000_000, iconSymbol: "building.columns.fill", colorHex: "#3498DB"))
            .frame(width: 300)
            .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
        }
        .padding()
}
