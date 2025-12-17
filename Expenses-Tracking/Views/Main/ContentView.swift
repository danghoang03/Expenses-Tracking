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
                Label("Tổng quan", systemImage: "house.fill")
            }
            .tag(Tab.dashboard)
            
            TransactionListView(path: $transactionPath)
                .tabItem {
                    Label("Sổ giao dịch", systemImage: "list.bullet.rectangle.portrait.fill")
                }
                .tag(Tab.transaction)
            
            BudgetListView(path: $budgetPath)
                .tabItem {
                    Label("Ngân sách", systemImage: "chart.bar.fill")
                }
                .tag(Tab.budget)
            
            NavigationStack {
                ReportView()
            }
            .tabItem {
                Label("Báo cáo", systemImage: "chart.pie.fill")
            }
            .tag(Tab.report)
            
            SettingsView(path: $settingsPath)
                .tabItem {
                    Label("Cài đặt", systemImage: "gearshape.fill")
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
