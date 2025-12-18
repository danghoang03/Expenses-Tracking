//
//  WalletSelectionCardView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 19/11/25.
//

import SwiftUI

struct WalletSelectionCardView: View {
    let wallet: Wallet
    let isSelected: Bool
    
    var customBalance: Double? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: wallet.iconSymbol)
                    .font(.title2)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
                }
            }
            
            Spacer()
            
            Text(wallet.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Text((customBalance ?? wallet.currentBalance).formatted(.currency(code: AppStrings.General.currencyVND)))
                .font(.caption2)
                .opacity(0.8)
                
        }
        .padding(12)
        .frame(width: 140, height: 100)
        .foregroundStyle(isSelected ? .white : .primary)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: wallet.colorHex))
                    .shadow(color: Color(hex: wallet.colorHex).opacity(0.4), radius: 4, x: 0, y: 2)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .stroke(Color.gray.opacity(12), lineWidth: 1)
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

#Preview {
    WalletSelectionCardView(wallet: Wallet(name: "Tiền mặt", initialBalance: 5_000_000, iconSymbol: "banknote", colorHex: "#2ECC71"), isSelected: true)
}
