//
//  ReportViewModel.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 25/11/25.
//

import Foundation
import SwiftData
import Observation

@Observable
class ReportViewModel {
    
    enum TimeRange: String, CaseIterable, Identifiable {
        case week = "Tuần"
        case month = "Tháng"
        case year = "Năm"
        
        var id: String { self.rawValue }
    }
    
    struct ChartData: Identifiable {
        let id = UUID()
        let label: String
        let date: Date
        let amount: Double
        let isCurrent: Bool
    }
    
    struct CategoryData: Identifiable {
        let id = UUID()
        let categoryName: String
        let colorHex: String
        let icon: String
        let amount: Double
        let percentage: Double
    }
    
    var timeRange: TimeRange = .week
    var chartData: [ChartData] = []
    var categoryData: [CategoryData] = []
    var totalSpent: Double = 0
    var averageSpent: Double = 0
    
    var maxAmount: Double { chartData.map(\.amount).max() ?? 0 }
    
    var maxChartAmount: Double {
        chartData.map(\.amount).max() ?? 0
    }
    
    @MainActor
    func fetchData(context: ModelContext) {
        var startDate: Date
        var endDate: Date
        
        switch timeRange {
        case .week:
            startDate = Date().startOfWeek
            endDate = Date().startOfNextWeek
            
        case .month:
            startDate = Date().startOfMonth
            endDate = Date().startOfNextMonth
            
        case .year:
            startDate = Date().startOfYear
            endDate = Date().startOfNextYear
        }
        
        let descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate<Transaction> { transaction in
            transaction.createdAt >= startDate &&
            transaction.createdAt < endDate
        })
        
        do {
            let transactions = try context.fetch(descriptor)
            
            let expenses = transactions.filter { $0.category?.type == .expense }
            
            self.totalSpent = expenses.reduce(0) { $0 + $1.amount }
            processChartData(expenses: expenses, range: timeRange, startDate: startDate, endDate: endDate)
            processCategoryData(expenses: expenses)
            
        } catch {
            print("Error fetching report data: \(error)")
        }
    }
    
    private func processChartData(expenses: [Transaction], range: TimeRange, startDate: Date, endDate: Date) {
        let calendar = Calendar.current
        var data: [ChartData] = []
        
        switch range {
        case .week:
            for i in 0..<7 {
                guard let date = calendar.date(byAdding: .day, value: i, to: startDate) else { continue }
                
                let dailyTotal = expenses
                    .filter { calendar.isDate($0.createdAt, inSameDayAs: date)}
                    .reduce(0) { $0 + $1.amount }
                
                let weekday = calendar.component(.weekday, from: date)
                let label = weekday == 1 ? "CN" : "T\(weekday)"
                let isToday = calendar.isDateInToday(date)
                
                data.append(ChartData(label: label, date: date, amount: dailyTotal, isCurrent: isToday))
            }
            
        case .month:
            var cursorDate = startDate
            
            while cursorDate < endDate {
                guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: cursorDate) else { break }
                
                let start = max(weekInterval.start, startDate)
                let end = min(weekInterval.end, endDate)
                
                if start >= end { break }
                
                let weeklyTotal = expenses.filter {
                    $0.createdAt >= start &&
                    $0.createdAt < end
                }.reduce(0) { $0 + $1.amount }
                
                let startDay = calendar.component(.day, from: start)
                let endDayDate = calendar.date(byAdding: .day, value: -1, to: end) ?? end
                let endDay = calendar.component(.day, from: endDayDate)
                
                let label = "\(startDay)-\(endDay)"
                
                let isCurrentWeek = (start...end).contains(Date())
                
                data.append(ChartData(label: label, date: start, amount: weeklyTotal, isCurrent: isCurrentWeek))
                
                cursorDate = end
            }
        case .year:
            for i in 0..<12 {
                guard let date = calendar.date(byAdding: .month, value: i, to: startDate) else { continue }
                let monthTotal = expenses
                    .filter { calendar.isDate($0.createdAt, equalTo: date, toGranularity: .month) }
                    .reduce(0) { $0 + $1.amount }
                
                let label = "T\(calendar.component(.month, from: date))"
                let isCurrentMonth = calendar.isDate(Date(), equalTo: date, toGranularity: .month)
                
                data.append(ChartData(label: label, date: date, amount: monthTotal, isCurrent: isCurrentMonth))
            }
        }
        
        self.chartData = data
        self.averageSpent = data.isEmpty ? 0 : (totalSpent / Double(data.count))
    }
    
    private func processCategoryData(expenses: [Transaction]) {
        guard totalSpent > 0 else {
            self.categoryData = []
            return
        }
        
        let grouped = Dictionary(grouping: expenses) { $0.category }
        
        self.categoryData = grouped.compactMap { (category, transactions) in
            guard let category = category else { return nil }
            let amount = transactions.reduce(0) { $0 + $1.amount }
            return CategoryData(
                categoryName: category.name,
                colorHex: category.colorHex,
                icon: category.iconSymbol,
                amount: amount,
                percentage: amount / self.totalSpent
            )
        }
        .sorted { $0.amount > $1.amount }
    }
    
    func getComparisonText(for item: ChartData) -> String? {
        guard timeRange == .year else { return nil }
        let calendar = Calendar.current
        guard let prevDate = calendar.date(byAdding: .month, value: -1, to: item.date),
                let prevItem = chartData.first(where: { calendar.isDate($0.date, equalTo: prevDate, toGranularity: .month) }) else { return nil }
        if prevItem.amount == 0 { return item.amount > 0 ? "+100%" : "0%" }
        let diff = (item.amount - prevItem.amount) / prevItem.amount
        let percentage = diff * 100
        let sign = diff > 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", percentage))%"
    }
}
