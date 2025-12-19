//
//  DashboardMetricView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 19/12/25.
//

import SwiftUI

struct DashboardMetricView: View {
    let title: String
    let value: Double
    let systemImage: String
    let tint: Color
    
    var body: some View {
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
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.white.opacity(0.14), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(value.formatted(.currency(code: AppStrings.General.currencyVND)))
    }
}
