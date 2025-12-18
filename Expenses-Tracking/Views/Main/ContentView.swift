//
//  ContentView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 14/11/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    enum Tab {
        case dashboard, transaction, budget, report, settings
    }
    
    @State private var selectedTab: Tab = .dashboard
    
    @State private var transactionPath = NavigationPath()
    @State private var budgetPath = NavigationPath()
    @State private var settingsPath = NavigationPath()
    
    var body: some View {
        let tabBinding = Binding<Tab>(
            get: { selectedTab },
            set: { newTab in
                if newTab == selectedTab {
                    resetPath(for: newTab)
                } else {
                    resetPath(for: newTab)
                    selectedTab = newTab
                }
            }
        )
        
        TabView(selection: tabBinding) {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label(AppStrings.Dashboard.title, systemImage: "house.fill")
            }
            .tag(Tab.dashboard)
            
            TransactionListView(path: $transactionPath)
                .tabItem {
                    Label(AppStrings.Transaction.listTitle, systemImage: "list.bullet.rectangle.portrait.fill")
                }
                .tag(Tab.transaction)
            
            BudgetListView(path: $budgetPath)
                .tabItem {
                    Label(AppStrings.Budget.title, systemImage: "chart.bar.fill")
                }
                .tag(Tab.budget)
            
            NavigationStack {
                ReportView()
            }
            .tabItem {
                Label(AppStrings.Report.title, systemImage: "chart.pie.fill")
            }
            .tag(Tab.report)
            
            SettingsView(path: $settingsPath)
                .tabItem {
                    Label(AppStrings.Settings.title, systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
    }
    
    private func resetPath(for tab: Tab) {
        switch tab {
        case .transaction: transactionPath = NavigationPath()
        case .budget: budgetPath = NavigationPath()
        case .settings: settingsPath = NavigationPath()
        case .report: break
        case .dashboard: break
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewContainer.shared)
}
