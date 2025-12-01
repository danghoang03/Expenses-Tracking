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
    @State private var selectedCategoryName: String?
    @State private var chartScrollPosition: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    timeFilterSection
                    summaryCard
                    barChartSection
                    donutChartSection
                    Color.clear.frame(height: 20)
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Báo cáo")
            .onAppear {
                viewModel.fetchData(context: modelContext)
            }
            .onChange(of: transactions) {
                viewModel.fetchData(context: modelContext)
            }
            .onChange(of: viewModel.timeRange) {
                viewModel.fetchData(context: modelContext)
                
                if viewModel.timeRange == . year {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollToCurrentItem()
                    }
                }
            }
        }
    }
}

extension ReportView {
    
    private var timeFilterSection: some View {
        Picker("Thời gian", selection: $viewModel.timeRange) {
            ForEach(ReportViewModel.TimeRange.allCases) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private var summaryCard: some View {
        VStack(spacing: 8) {
            Text("Tổng chi tiêu")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(viewModel.totalSpent.formatted(.currency(code: "VND")))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.red)
                .contentTransition(.numericText())
                .animation(.default, value: viewModel.totalSpent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var barChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Xu hướng chi tiêu", systemImage: "chart.bar.fill")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal)
            
            barChartView
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
        }
    }
    
    private var barChartView: some View {
        VStack(alignment: .leading) {
            Text("Đơn vị: VNĐ")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
                    
            Chart {
                barMarksLayer
                averageLineLayer
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: viewModel.chartData.map { $0.date }) { value in
                        if let date = value.as(Date.self),
                            let item = viewModel.chartData.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                            AxisValueLabel {
                                Text(item.label)
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) {
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
                .chartScrollPosition(x: $chartScrollPosition)
                .chartScrollableAxes(viewModel.timeRange == .year ? .horizontal : [])
                .applyChartDomain(isYearMode: viewModel.timeRange == .year)
            }
    }
    
    @ChartContentBuilder
    private var barMarksLayer: some ChartContent {
        ForEach(viewModel.chartData) { item in
            BarMark(
                x: .value("Date", item.date, unit: unitForRange),
                y: .value("Amount", item.amount)
            )
            .foregroundStyle(item.isCurrent ? .blue : .blue.opacity(0.3))
            .cornerRadius(4)
            .annotation(position: .top, spacing: 4) {
                annotationView(for: item)
            }
        }
    }
        
    @ChartContentBuilder
    private var averageLineLayer: some ChartContent {
        if viewModel.averageSpent > 0 {
            RuleMark(y: .value("Average", viewModel.averageSpent))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                .foregroundStyle(.gray.opacity(0.5))
                .annotation(position: .leading, alignment: .bottom) {
                    Text("Trung bình")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
        }
    }
    
    @ViewBuilder
    private func annotationView(for item: ReportViewModel.ChartData) -> some View {
        if item.isCurrent && item.amount > 0 {
            Text(shortFormat(item.amount))
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
        }
    }
    
    private var unitForRange: Calendar.Component {
        switch viewModel.timeRange {
        case .week: return .day 
        case .month: return .weekOfMonth
        case .year: return .month
        }
    }
    
    private func shortFormat(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "%.0fK", value / 1_000)
        }
        return String(format: "%.0f", value)
    }
    
    private func scrollToCurrentItem() {
        if let currentItem = viewModel.chartData.first(where: { $0.isCurrent }) {
            withAnimation {
                chartScrollPosition = currentItem.label
            }
        }
    }
    
    private var donutChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Cơ cấu chi tiêu", systemImage: "chart.pie.fill")
                .font(.headline)
                .padding(.horizontal)
            
            if viewModel.categoryData.isEmpty {
                emptyChartState
            } else {
                interactiveDonutChart
                detailedLegendList
            }
        }
    }
    
    private var interactiveDonutChart: some View {
        VStack {
            Chart(viewModel.categoryData) { item in
                SectorMark(
                    angle: .value("Số tiền", item.amount),
                    innerRadius: .ratio(0.6),
                    angularInset: 1.5
                )
                .cornerRadius(6)
                .foregroundStyle(Color(hex: item.colorHex))
                .opacity(selectedCategoryName == nil ? 1.0 : (selectedCategoryName == item.categoryName ? 1.0 : 0.3))
            }
            .frame(height: 300)
            .chartLegend(.hidden)
            .chartAngleSelection(value: $selectedCategoryName)
            .chartBackground { proxy in
                GeometryReader { geo in
                    if let plotFrame = proxy.plotFrame {
                        let frame = geo[plotFrame]
                        centerInfoView
                            .position(x: frame.midX, y: frame.midY)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var centerInfoView: some View {
        VStack(spacing: 4) {
            if let selectedName = selectedCategoryName,
               let selectedItem = viewModel.categoryData.first(where: { $0.categoryName == selectedName }) {
                Text(selectedItem.categoryName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(selectedItem.percentage.formatted(.percent.precision(.fractionLength(1))))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: selectedItem.colorHex))
                
                Text(selectedItem.amount.formatted(.currency(code: "VND")))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    
            } else {
                Text("Top 1")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if let topItem = viewModel.categoryData.first {
                    Text(topItem.categoryName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: topItem.colorHex))
                        .multilineTextAlignment(.center)
                    
                    Text(topItem.percentage.formatted(.percent.precision(.fractionLength(1))))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("--")
                        .font(.headline)
                }
            }
        }
    }
    
    private var detailedLegendList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.categoryData) { item in
                HStack(spacing: 12) {
                    Image(systemName: item.icon)
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Color(hex: item.colorHex))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.categoryName)
                            .font(.body)
                            .fontWeight(.medium)
                        
                        GeometryReader { geometry in
                            Capsule()
                                .fill(Color(hex: item.colorHex).opacity(0.3))
                                .frame(width: min(geometry.size.width * CGFloat(item.percentage), geometry.size.width), height: 4)
                        }
                        .frame(height: 4)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(item.amount.formatted(.currency(code: "VND")))
                            .fontWeight(.semibold)
                            .font(.callout)
                        
                        Text(item.percentage.formatted(.percent.precision(.fractionLength(1))))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(
                    (selectedCategoryName == item.categoryName)
                    ? Color(hex: item.colorHex).opacity(0.1)
                    : Color.clear
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring) {
                        if selectedCategoryName == item.categoryName {
                            selectedCategoryName = nil
                        } else {
                            selectedCategoryName = item.categoryName
                        }
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                
                if item.id != viewModel.categoryData.last?.id {
                    Divider().padding(.leading, 56)
                }
            }
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    private var emptyChartState: some View {
        ContentUnavailableView(
            "Chưa có dữ liệu",
            systemImage: "chart.pie",
            description: Text("Hãy thêm giao dịch chi tiêu để xem biểu đồ phân tích.")
        )
        .frame(height: 300)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

extension View {
    @ViewBuilder
    func applyChartDomain(isYearMode: Bool) -> some View {
        if isYearMode {
            self.chartXVisibleDomain(length: 15552000)
        } else {
            self
        }
    }
}

#Preview {
    ReportView()
        .modelContainer(PreviewContainer.shared)
}
