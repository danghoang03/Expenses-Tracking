//
//  CategoryRowView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 15/11/25.
//

import SwiftUI

struct CategoryRowView: View {
    let category: Category
    
    var body: some View {
        HStack {
            Image(systemName: category.iconSymbol)
                .foregroundStyle(Color(hex: category.colorHex))
                .frame(width: 30)
            Text(category.name)
            Spacer()
        }
    }
}

#Preview {
    CategoryRowView(category: Category(name: "Ăn uống", iconSymbol: "fork.knife", colorHex: "#F1C40F", type: .expense))
}
