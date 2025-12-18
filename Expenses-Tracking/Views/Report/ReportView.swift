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
    @State private var selectedBarDate: Date?
    
    private var initialScrollDate: Date {
        viewModel.chartData.first(where: { $0.isCurrent })?.date ?? Date()
    }
    
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
            .navigationTitle(AppStrings.Report.title)
            .onAppear {
                viewModel.fetchData(context: modelContext)
            }
            .onChange(of: transactions) {
                viewModel.fetchData(context: modelContext)
            }
            .onChange(of: viewModel.timeRange) {
                viewModel.fetchData(context: modelContext)
                selectedBarDate = nil
            }
            .onDisappear {
                selectedBarDate = nil
                viewModel.timeRange = .week
            }
        }
    }
}

extension ReportView {
    
    private var timeFilterSection: some View {
        Picker(AppStrings.Settings.time, selection: $viewModel.timeRange.animation(.easeInOut)) {
            ForEach(ReportViewModel.TimeRange.allCases) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private var summaryCard: some View {
        VStack(spacing: 8) {
            Text(AppStrings.Report.total)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(viewModel.totalSpent.formatted(.currency(code: AppStrings.General.currencyVND)))
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
            Label(AppStrings.Report.expenseTrend, systemImage: "chart.bar.fill")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal)
            
            if viewModel.totalSpent == 0 {
                emptyBarChartState
            } else {
                barChartView
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
            }
        }
    }
    
    private var barChartView: some View {
        VStack(alignment: .leading) {
            Text(AppStrings.Report.vndUnit)
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
                .chartYScale(domain: 0...(viewModel.maxChartAmount * 1.2))
                .chartGesture { proxy in
                    SpatialTapGesture().onEnded { value in
                        if let date = proxy.value(atX: value.location.x, as: Date.self) {
                            selectedBarDate = date
                        }
                    }
                }
                .chartScrollPosition(initialX: initialScrollDate)
                .chartScrollableAxes(viewModel.timeRange == .year ? .horizontal : [])
                .applyChartDomain(isYearMode: viewModel.timeRange == .year)
            }
    }
    
    private var emptyBarChartState: some View {
        ContentUnavailableView(
            AppStrings.Report.noData,
            systemImage: "chart.bar",
            description: Text(AppStrings.Report.noDataDesc)
        )
        .frame(height: 200)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    @ChartContentBuilder
    private var barMarksLayer: some ChartContent {
        ForEach(viewModel.chartData) { item in
            BarMark(
                x: .value("Date", item.date, unit: unitForRange),
                y: .value("Amount", item.amount)
            )
            .foregroundStyle(barForegroundStyle(for: item))
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
                    Text(AppStrings.Report.average)
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
        }
    }
    
    @ViewBuilder
    private func annotationView(for item: ReportViewModel.ChartData) -> some View {
        let isSelected = isBarSelected(item)
        
        if (item.isCurrent && selectedBarDate == nil && item.amount > 0) || (isSelected && item.amount > 0) {
            Text(shortFormat(item.amount))
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(isSelected ? .primary : .secondary)
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
    
    private func barForegroundStyle(for item: ReportViewModel.ChartData) -> some ShapeStyle {
        let isSelected = isBarSelected(item)
        
        if selectedBarDate != nil {
            return isSelected ? Color.blue : Color.blue.opacity(0.3)
        } else {
            return item.isCurrent ? Color.blue : Color.blue.opacity(0.3)
        }
    }
    
    private func isBarSelected(_ item: ReportViewModel.ChartData) -> Bool {
        guard let selectedDate = selectedBarDate else { return false }
        let calendar = Calendar.current
        
        switch viewModel.timeRange {
        case .week:
            return calendar.isDate(item.date, inSameDayAs: selectedDate)
        case .month:
            return calendar.isDate(item.date, equalTo: selectedDate, toGranularity: .weekOfYear)
        case .year:
            return calendar.isDate(item.date, equalTo: selectedDate, toGranularity: .month)
        }
    }
    
    private var donutChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(AppStrings.Report.expenseStructure, systemImage: "chart.pie.fill")
                .font(.headline)
                .padding(.horizontal)
            
            if viewModel.categoryData.isEmpty {
                emptyDonutChartState
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
                    angle: .value(AppStrings.Report.amount, item.amount),
                    innerRadius: .ratio(0.6),
                    angularInset: 1.5
                )
                .cornerRadius(6)
                .foregroundStyle(by: .value("Category", item.categoryName))
                .opacity(selectedCategoryName == nil ? 1.0 : (selectedCategoryName == item.categoryName ? 1.0 : 0.3))
            }
            .frame(height: 300)
            .chartLegend(.hidden)
            .chartForegroundStyleScale(
                domain: viewModel.categoryData.map(\.categoryName),
                range: viewModel.categoryData.map { Color(hex: $0.colorHex) }
            )
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
                
                Text(selectedItem.amount.formatted(.currency(code: AppStrings.General.currencyVND)))
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
                        Text(item.amount.formatted(.currency(code: AppStrings.General.currencyVND)))
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
    
    private var emptyDonutChartState: some View {
        ContentUnavailableView(
            AppStrings.Report.noData,
            systemImage: "chart.pie",
            description: Text(AppStrings.Report.noDataDonutDesc)
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
