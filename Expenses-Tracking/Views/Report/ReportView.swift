//
//  ReportView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 16/11/25.
//

import SwiftUI
import SwiftData
import Charts

struct ReportView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.createdAt, order: .reverse) private var transactions: [Transaction]
    @State private var viewModel = ReportViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    summaryCard
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Xu hướng chi tiêu", systemImage: "char.bar.fill")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .padding(.horizontal)
                        
                        barChartView
                            .padding()
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Cơ cấu danh mục", systemImage: "char.pie.fill")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .padding(.horizontal)
                        
                        pieChartView
                            .padding()
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                    }
                    
                    Color.clear.frame(height: 20)
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Báo cáo")
            .onAppear {
                viewModel.processData(context: modelContext)
            }
            .onChange(of: transactions) {
                viewModel.processData(context: modelContext)
            }
        }
    }
}

extension ReportView {
    
    private var summaryCard: some View {
        VStack(spacing: 8) {
            Text("Tổng chi tiêu tháng này")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(viewModel.totalSpent.formatted(.currency(code: "VND")))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.red)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    private var barChartView: some View {
        Chart {
            ForEach(viewModel.dailyExpenses) { item in
                BarMark(
                    x: .value("Ngày", item.date, unit: .day),
                    y: .value("Số tiền", item.amount)
                )
                .foregroundStyle(Color.blue.gradient)
            }
        }
        .frame(height: 300)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisValueLabel(format: .dateTime.day())
            }
        }
    }
    
    private var pieChartView: some View {
        Chart(viewModel.categoryExpenses) { item in
            SectorMark(
                angle: .value("Số tiền", item.amount),
                innerRadius: .ratio(0.6),
                angularInset: 1.5
            )
            .cornerRadius(6)
            .foregroundStyle(Color(hex: item.colorHex))
            .annotation(position: .overlay) {
                if item.amount / viewModel.totalSpent > 0.1 {
                    Image(systemName: item.icon)
                        .foregroundStyle(.white)
                        .font(.caption)
                }
            }
        }
        .frame(height: 300)
        .chartBackground { proxy in
            GeometryReader { geo in
                if let plotFrame = proxy.plotFrame {
                    let frame = geo[plotFrame]
                    VStack {
                        Text("Top 1")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let topCat = viewModel.categoryExpenses.first {
                            Text(topCat.categoryName)
                                .font(.headline)
                                .foregroundStyle(Color(hex: topCat.colorHex))
                        }
                    }
                    .position(x: frame.midX, y: frame.midY)
                }
            }
        }
    }
}

#Preview {
    ReportView()
        .modelContainer(PreviewContainer.shared)
}
