//
//  WalletCardView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 16/11/25.
//

import SwiftUI

struct WalletCardView: View {
    let wallet: Wallet
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            backgroundLayer
            decorativeLayer
            contentLayer
        }
        .frame(height: 140)
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
                    .font(.system(size: 80))
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
            Spacer()
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
                .lineLimit(1)
            
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
        }
    }
}

#Preview {
    WalletCardView(wallet: Wallet(name: "Tiền mặt", initialBalance: 5_000_000, iconSymbol: "banknote", colorHex: "#2ECC71"))
        .padding()
}
