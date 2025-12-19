//
//  DashboardOverviewCard.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 19/12/25.
//

import SwiftUI

struct DashboardOverviewCard: View {
    let totalBalance: Double
    let income: Double
    let expense: Double
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var balanceFontSize: CGFloat = 36
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            balanceHeader
            
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 12) {
                    metricViews(isHorizontal: false)
                }
            } else {
                HStack(spacing: 12) {
                    metricViews(isHorizontal: true)
                }
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
    }
    
    private var balanceHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(AppStrings.Dashboard.totalBalance)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))

                Text(totalBalance.formatted(.currency(code: AppStrings.General.currencyVND)))
                    .font(.system(size: balanceFontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(AppStrings.Dashboard.totalBalance)
            .accessibilityValue(totalBalance.formatted(.currency(code: AppStrings.General.currencyVND)))

            Spacer()

            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))
                .padding(10)
                .background(.white.opacity(0.16), in: Circle())
        }
    }
    
    private func metricViews(isHorizontal: Bool) -> some View {
        Group {
            DashboardMetricView(
                title: AppStrings.Dashboard.monthlyIncome,
                value: income,
                systemImage: "arrow.down.left",
                tint: .green
            )
            .frame(maxWidth: isHorizontal ? .infinity : nil)
            
            DashboardMetricView(
                title: AppStrings.Dashboard.monthlyExpense,
                value: expense,
                systemImage: "arrow.up.right",
                tint: .red
            )
            .frame(maxWidth: isHorizontal ? .infinity : nil)
        }
    }
}

#Preview {
    VStack {
        DashboardOverviewCard(totalBalance: 15000000, income: 5000000, expense: 2000000)
        
        DashboardOverviewCard(totalBalance: 15000000, income: 5000000, expense: 2000000)
            .environment(\.dynamicTypeSize, .accessibility3)
    }
    .padding()
}
