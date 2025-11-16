//
//  SettingsView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 16/11/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    
    var body: some View {
        List {
            Section("Dữ liệu nguồn") {
                ForEach(viewModel.menuItems, id: \.self) { item in
                    NavigationLink(value: item) {
                        Label(item.title, systemImage: item.icon)
                    }
                }
            }
                        
            Section("Ứng dụng") {
                Text("Phiên bản 1.0.0")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Cài đặt")
        .navigationDestination(for: SettingsViewModel.Route.self) { route in
            switch route {
            case .wallets:
                WalletListView()
            case .categories:
                CategoryListView()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(PreviewContainer.shared)
}
