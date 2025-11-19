//
//  ContentView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 14/11/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Tổng quan", systemImage: "house.fill")
            }
            
            NavigationStack {
                TransactionListView()
            }
            .tabItem {
                Label("Sổ giao dịch", systemImage: "list.bullet.rectangle.portrait.fill")
            }
            
            NavigationStack {
                ReportView()
            }
            .tabItem {
                Label("Báo cáo", systemImage: "chart.pie.fill")
            }
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                    Label("Cài đặt", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewContainer.shared)
}
