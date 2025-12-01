//
//  PieChartLabelView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 29/11/25.
//

import SwiftUI

struct PieChartLabelView: View {
    let icon: String
    let percentage: String
    let name: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
            
            Text(percentage)
                .fontWeight(.bold)
                .foregroundStyle(color)
            
            Text(name)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}

#Preview {
    PieChartLabelView(icon: "fork.knife", percentage: "20%", name: "Ăn uống", color: Color(hex: "F1C40F"))
}
