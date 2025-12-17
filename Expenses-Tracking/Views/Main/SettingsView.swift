//
//  SettingsView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 16/11/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SettingsViewModel()
    
    @Binding var path: NavigationPath
    
    @State private var csvURL: URL?
    @State private var showingShareSheet = false
    @State private var isExporting = false
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section("Dữ liệu nguồn") {
                    ForEach(viewModel.menuItems, id: \.self) { item in
                        NavigationLink(value: item) {
                            Label(item.title, systemImage: item.icon)
                        }
                    }
                }
                
                Section("Thông báo") {
                    Toggle(isOn: $viewModel.isReminderEnabled) {
                        Label("Nhắc nhở hàng ngày", systemImage:  "bell.fill")
                            .tint(.blue)
                    }
                    
                    if viewModel.isReminderEnabled {
                        DatePicker(selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute) {
                            Label("Thời gian", systemImage: "clock")
                        }
                        .datePickerStyle(.compact)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                
                Section("Dữ liệu & Sao lưu") {
                    Button {
                        exportData()
                    } label: {
                        if isExporting {
                            HStack {
                                Text("Đang xuất dữ liệu...")
                                Spacer()
                                ProgressView()
                            }
                        } else {
                            Label("Xuất file CSV", systemImage: "square.and.arrow.up")
                        }
                    }
                    .disabled(isExporting)
                }
                
                Section("Ứng dụng") {
                    HStack {
                        Text("Phiên bản")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
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
            .sheet(isPresented: $showingShareSheet) {
                if let url = csvURL {
                    ShareSheet(items: [url])
                }
            }
            .alert("Cấp quyền thông báo", isPresented: $viewModel.showPermissionAlert) {
                Button("Hủy", role: .cancel) { }
                Button("Cài đặt") {
                    viewModel.openSystemSettings()
                }
            } message: {
                Text("Ứng dụng cần quyền thông báo để nhắc nhở bạn. Vui lòng bật trong Cài đặt.")
            }
            .animation(.default, value: viewModel.isReminderEnabled)
        }
    }
}

extension SettingsView {
    private func exportData() {
        isExporting = true
        
        Task {
            let descriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            
            do {
                let allTransactions = try modelContext.fetch(descriptor)
                
                if let url = CSVManager.generateCSV(from: allTransactions) {
                    await MainActor.run {
                        self.csvURL = url
                        self.isExporting = false
                        self.showingShareSheet = true
                    }
                } else {
                    await MainActor.run { isExporting = false }
                }
            } catch {
                print("Error failed: \(error)")
                await MainActor.run { isExporting = false }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(path: .constant(NavigationPath()))
    }
    .modelContainer(PreviewContainer.shared)
}
