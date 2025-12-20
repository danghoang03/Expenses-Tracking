# ``Expenses_Tracking``

A Personal Finance Management application built with **SwiftData** and **SwiftUI**.

## Overview

Expenses-Tracking is an iOS application designed to help users track income, expenses, manage budgets, and visualize financial reports.

This project leverages Apple's latest technologies:
- **Architecture**: MVVM (Model-View-ViewModel).
- **Database**: SwiftData for local persistence.
- **UI**: SwiftUI.
- **Concurrency**: Swift Async/Await.

## Topics

### Data Models (SwiftData)
The core data structure of the application, defined using the `@Model` macro.

- ``Transaction``
- ``Category``
- ``Wallet``
- ``Budget``
- ``TransactionType``

### Business Logic & Services
The layer responsible for business rules, data calculation, and external API communication.

- ``TransactionManager``
- ``CurrencyService``
- ``CurrencyServiceProtocol``
- ``NotificationManager``
- ``CSVManager``

### Features

#### Dashboard
An overview screen displaying total balance, monthly summary, and recent transactions.
- ``DashboardView``
- ``DashboardViewModel``
- ``DashboardOverviewCard``
- ``DashboardMetricView``

#### Transaction Management
Manage transaction lists, create/edit/delete operations, and search filtering.
- ``TransactionListView``
- ``TransactionListViewModel``
- ``AddTransactionView``
- ``TransactionDetailView``
- ``TransactionFilterView``

#### Budgeting
Set spending limits and track budget progress.
- ``BudgetListView``
- ``BudgetViewModel``
- ``AddBudgetView``
- ``BudgetDetailView``

#### Reporting
Visualize financial data to analyze spending trends.
- ``ReportView``
- ``ReportViewModel``

#### Settings & Configuration
App configuration, wallet management, category management, and data backup.
- ``SettingsView``
- ``SettingsViewModel``
- ``AddWalletView``
- ``AddCategoryView``

### Utilities & Extensions
Helper extensions to keep the code clean and reusable.

- ``AppStrings``
- ``CurrencyViewModel``

