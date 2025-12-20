//
//  ReportViewModelTests.swift
//  Expenses-TrackingTests
//
//  Created by Hoàng Minh Hải Đăng on 20/12/25.
//

import XCTest
import SwiftData
@testable import Expenses_Tracking

@MainActor
final class ReportViewModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var viewModel: ReportViewModel!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Transaction.self, Wallet.self, Category.self, configurations: config)
        context = container.mainContext
        viewModel = ReportViewModel()
    }
    
    override func tearDown() {
        container = nil
        context = nil
        viewModel = nil
        super.tearDown()
    }

    // Test Case 1: Total Expense Calculation
    // Verifies that the ViewModel correctly sums up 'expense' transactions and ignores 'income'.
    func testFetchData_CalculatesTotalSpentCorrectly() {
        // 1. Arrange
        let category = Category(name: "Food", iconSymbol: "", colorHex: "", type: .expense)
        context.insert(category)
        
        // Create 2 expense transaction this week
        let t1 = Transaction(amount: 100_000, createdAt: Date(), note: "T1", category: category)
        let t2 = Transaction(amount: 200_000, createdAt: Date(), note: "T2", category: category)
        
        // Create 1 income transaction this week (not included in total Spend)
        let incomeCat = Category(name: "Salary", iconSymbol: "", colorHex: "", type: .income)
        let t3 = Transaction(amount: 500_000, createdAt: Date(), note: "T3", category: incomeCat)
        
        context.insert(t1); context.insert(t2); context.insert(t3);
        context.insert(incomeCat)

        // 2. Act
        viewModel.timeRange = .week
        viewModel.fetchData(context: context)

        // 3. Assert
        XCTAssertEqual(viewModel.totalSpent, 300_000, "Total expenses must be 300k (excluding income).")
    }
    
    // Test Case 2: Chart Data - Year Grouping
    // Verifies that when 'Year' is selected, data is correctly grouped into 12 months.
    func testFetchData_YearRange_GroupsByMonthCorrectly() {
        // 1. Arrange
        let category = Category(name: "Food", iconSymbol: "", colorHex: "", type: .expense)
        context.insert(category)
            
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
            
        // Helper to create date in specific month of current year
        func dateInMonth(_ month: Int) -> Date {
            return calendar.date(from: DateComponents(year: currentYear, month: month, day: 15))!
        }
            
        // Add transaction in Jan (Month 1)
        let t1 = Transaction(amount: 100, createdAt: dateInMonth(1), category: category)
        // Add transaction in Feb (Month 2)
        let t2 = Transaction(amount: 200, createdAt: dateInMonth(2), category: category)
            
        context.insert(t1); context.insert(t2)
            
        // 2. Act
        viewModel.timeRange = .year
        viewModel.fetchData(context: context)
            
        // 3. Assert
        XCTAssertEqual(viewModel.totalSpent, 300, "Total spent should cover the whole year")
        XCTAssertEqual(viewModel.chartData.count, 12, "Chart data should always have 12 bars for 12 months")
            
        // Check Jan Data
        let janData = viewModel.chartData.first { $0.label == "T1" }
        XCTAssertEqual(janData?.amount, 100, "January spending should be 100")
            
        // Check Feb Data
        let febData = viewModel.chartData.first { $0.label == "T2" }
        XCTAssertEqual(febData?.amount, 200, "February spending should be 200")
            
        // Check Mar Data (Should be 0)
        let marData = viewModel.chartData.first { $0.label == "T3" }
        XCTAssertEqual(marData?.amount, 0, "March spending should be 0")
    }
    
    // Test Case 3: Chart Data - Week Grouping
    // Verifies that when 'Week' is selected, data is grouped by day (Mon, Tue, etc.).
    func testChartData_WeekRange_GroupsByDayCorrectly() {
        // 1. Arrange
        let category = Category(name: "Food", iconSymbol: "", colorHex: "", type: .expense)
        context.insert(category)
            
        let today = Date()
        let t1 = Transaction(amount: 150_000, createdAt: today, category: category)
        context.insert(t1)
            
        // 2. Act
        viewModel.timeRange = .week
        viewModel.fetchData(context: context)
            
        // 3. Assert
        let calendar = Calendar.current
        // Find the bar corresponding to 'today'
        let todayData = viewModel.chartData.first { calendar.isDate($0.date, inSameDayAs: today) }
            
        XCTAssertNotNil(todayData, "There should be data for today")
        XCTAssertEqual(todayData?.amount, 150_000, "Data for today should match the transaction amount")
        XCTAssertEqual(viewModel.chartData.count, 7, "Chart data should have 7 bars for 7 days of the week")
    }

    // Test Case 4: Category Data - Pie Chart Logic
    // Verifies that expenses are grouped by category, sorted by amount, and percentages are calculated correctly.
    func testCategoryData_CalculatesPercentagesAndSortsCorrectly() {
        // 1. Arrange
        let foodCat = Category(name: "Food", iconSymbol: "", colorHex: "", type: .expense)
        let transportCat = Category(name: "Transport", iconSymbol: "", colorHex: "", type: .expense)
        context.insert(foodCat)
        context.insert(transportCat)
            
        // Food: 60k
        context.insert(Transaction(amount: 60_000, createdAt: Date(), category: foodCat))
        // Transport: 40k
        context.insert(Transaction(amount: 40_000, createdAt: Date(), category: transportCat))
            
        // 2. Act
        viewModel.timeRange = .week // or any range that covers 'Date()'
        viewModel.fetchData(context: context)
    
        // 3. Assert
        XCTAssertEqual(viewModel.totalSpent, 100_000, "Total spent should be 100k")
        XCTAssertEqual(viewModel.categoryData.count, 2, "Should have 2 category segments")
            
        // Validate Sorting (Highest amount first)
        let firstItem = viewModel.categoryData[0]
        XCTAssertEqual(firstItem.categoryName, "Food", "Food should be first because 60k > 40k")
        
        // Validate Percentage
        // Food: 60k / 100k = 0.6
        XCTAssertEqual(firstItem.percentage, 0.6, accuracy: 0.001, "Food should be 60% of total")
    
        let secondItem = viewModel.categoryData[1]
        XCTAssertEqual(secondItem.categoryName, "Transport")
        XCTAssertEqual(secondItem.percentage, 0.4, accuracy: 0.001, "Transport should be 40% of total")
    }
    
    // Test Case 5: Empty State
    // Verifies that the ViewModel handles the no-data state gracefully.
    func testFetchData_NoTransactions_ReturnsEmptyData() {
        // 1. Arrange
        // No transactions inserted
            
        // 2. Act
        viewModel.fetchData(context: context)
            
        // 3. Assert
        XCTAssertEqual(viewModel.totalSpent, 0, "Total spent should be 0")
        XCTAssertTrue(viewModel.categoryData.isEmpty, "Category data should be empty")
    }
}
