//
//  TransactionManagerTests.swift
//  Expenses-TrackingTests
//
//  Created by Hoàng Minh Hải Đăng on 20/12/25.
//

import XCTest
import SwiftData
@testable import Expenses_Tracking

@MainActor
final class TransactionManagerTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    
    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Transaction.self, Wallet.self, Category.self, Budget.self, configurations: config)
        context = container.mainContext
    }
    
    override func tearDownWithError() throws {
        container = nil
        context = nil
    }
    
    // Test Case 1: Add an expense -> Money must be deducted from the wallet
    func testAddTransaction_Expense_DeductsBalance() throws {
        // 1. Arrange
        let wallet = Wallet(name: "Test Wallet", initialBalance: 1_000_000, iconSymbol: "", colorHex: "")
        context.insert(wallet)
        
        let category = Category(name: "Food", iconSymbol: "", colorHex: "", type: .expense)
        context.insert(category)
        
        // 2. Act
        try TransactionManager.addTransaction(
            amount: 200_000,
            date: Date(),
            note: "Dinner",
            category: category,
            wallet: wallet,
            destinationWallet: nil,
            context: context
        )
        
        // 3. Assert
        XCTAssertEqual(wallet.currentBalance, 800_000, "The wallet balance must decrease by 200k")
                       
        // Check if the transaction has been saved
        let descriptor = FetchDescriptor<Transaction>()
        let transactions = try context.fetch(descriptor)
        XCTAssertEqual(transactions.count, 1)
        XCTAssertEqual(transactions.first?.amount, 200_000)
    }
    
    // Test Case 2: Add an income -> Money must be increase in the wallet
    func testAddTransaction_Income_IncreasesBalance() throws {
        // 1. Arrange
        let wallet = Wallet(name: "Test Wallet", initialBalance: 1_000_000, iconSymbol: "", colorHex: "")
        context.insert(wallet)
    
        let category = Category(name: "Salary", iconSymbol: "", colorHex: "", type: .income)
        context.insert(category)
            
        // 2. Act
        try TransactionManager.addTransaction(
            amount: 500_000,
            date: Date(),
            note: "Bonus",
            category: category,
            wallet: wallet,
            destinationWallet: nil,
            context: context
        )
            
        // 3. Assert
        XCTAssertEqual(wallet.currentBalance, 1_500_000, "The wallet balance must increase by 500k")
    }
    
    // Test Case 3: Transfer -> Source wallet decrease, Dest wallet increase
    func testAddTransaction_Transfer_UpdatesBothWallets() throws {
        // 1. Arrange
        let sourceWallet = Wallet(name: "Source", initialBalance: 2_000_000, iconSymbol: "", colorHex: "")
        context.insert(sourceWallet)
        
        let destWallet = Wallet(name: "Dest", initialBalance: 0, iconSymbol: "", colorHex: "")
        context.insert(destWallet)
            
        let category = Category(name: "Transfer", iconSymbol: "", colorHex: "", type: .transfer)
        context.insert(category)
            
        // 2. Act
        try TransactionManager.addTransaction(
            amount: 500_000,
            date: Date(),
            note: "Save",
            category: category,
            wallet: sourceWallet,
            destinationWallet: destWallet,
            context: context
        )
            
        // 3. Assert
        XCTAssertEqual(sourceWallet.currentBalance, 1_500_000, "The source wallet must be decrease by 500k")
        XCTAssertEqual(destWallet.currentBalance, 500_000, "The destination wallet must be increase by 500k")
    }
    
    // Test Case 4: Delete transaction -> Revert Balance
    func testDeleteTransaction_RevertsBalance() throws {
        // 1. Arrange
        let wallet = Wallet(name: "Test Wallet", initialBalance: 1_000_000, iconSymbol: "", colorHex: "")
        context.insert(wallet)
        
        let category = Category(
            name: "Food",
            iconSymbol: "",
            colorHex: "",
            type: .expense
        )
        context.insert(category)
            
        // Create transaction (wallet will have 900k)
        try TransactionManager.addTransaction(
            amount: 100_000,
            date: Date(),
            note: "Lunch",
            category: category,
            wallet: wallet,
            destinationWallet: nil,
            context: context
        )
            
        let descriptor = FetchDescriptor<Transaction>()
        let transactions = try context.fetch(descriptor)
        let transactionToDelete = transactions.first!
            
        // 2. Act
        TransactionManager.deleteTransaction(transactionToDelete, context: context)
            
        // 3. Assert
        XCTAssertEqual(wallet.currentBalance, 1_000_000, "After delete a transaction, money must be restored to the wallet")
        let count = try context.fetchCount(FetchDescriptor<Transaction>())
        XCTAssertEqual(count, 0)
    }
    
    // Test Case 5: Update Amount -> The wallet must update with the correct difference
    func testUpdateTransaction_ChangeAmount_UpdatesBalance() throws {
        // 1. Arrange:
        let wallet = Wallet(name: "Test Wallet", initialBalance: 1_000_000, iconSymbol: "", colorHex: "")
        context.insert(wallet)
        
        let category = Category(name: "Food", iconSymbol: "", colorHex: "", type: .expense)
        context.insert(category)
            
        try TransactionManager.addTransaction(
            amount: 100_000,
            date: Date(),
            note: "Lunch",
            category: category,
            wallet: wallet,
            destinationWallet: nil,
            context: context
        )
            
        let transaction = try context.fetch(FetchDescriptor<Transaction>()).first!
            
        // 2. Act: Change spending from 100k to 200k
        // Correct logic: 100k refund (wallet balance becomes 1 million)
        // -> 200k deduction (wallet balance becomes 800k)
        try TransactionManager.updateTransaction(
            transaction: transaction,
            newAmount: 200_000,
            newDate: Date(),
            newNote: "Buffet",
            newCategory: category,
            newWallet: wallet,
            newDestinationWallet: nil,
            context: context
        )
            
        // 3. Assert
        XCTAssertEqual(wallet.currentBalance, 800_000, "The wallet balance must reflect the new amount (1M - 200K = 800K)")
        XCTAssertEqual(transaction.amount, 200_000)
    }

    // Test Case 6: Change Wallet -> Old wallet gets refunded, new wallet is charged.
    func testUpdateTransaction_ChangeWallet_UpdatesBothWallets() throws {
        // 1. Arrange:
        let walletA = Wallet(name: "Wallet A", initialBalance: 1_000_000, iconSymbol: "", colorHex: "")
        context.insert(walletA)
        
        let walletB = Wallet(name: "Wallet B", initialBalance: 1_000_000, iconSymbol: "", colorHex: "")
        context.insert(walletB)
        
        let category = Category(name: "Food", iconSymbol: "", colorHex: "", type: .expense)
        context.insert(category)
            
        try TransactionManager.addTransaction(
            amount: 100_000,
            date: Date(),
            note: "Lunch",
            category: category,
            wallet: walletA,
            destinationWallet: nil,
            context: context
        )
            
        // Check initial balance: A has 900k remaining, B has 1 million remaining.
        XCTAssertEqual(walletA.currentBalance, 900_000)
            
        let transaction = try context.fetch(FetchDescriptor<Transaction>()).first!
            
        // 2. Act: Change payment wallet from A to B
        try TransactionManager.updateTransaction(
            transaction: transaction,
            newAmount: 100_000,
            newDate: Date(),
            newNote: "Lunch",
            newCategory: category,
            newWallet: walletB,
            newDestinationWallet: nil,
            context: context
        )
            
        // 3. Assert
        XCTAssertEqual(walletA.currentBalance, 1_000_000, "Wallet A must be refunded (to 1M)")
        XCTAssertEqual(walletB.currentBalance, 900_000, "Wallet B must have money deducted (900k remaining).")
    }
}
