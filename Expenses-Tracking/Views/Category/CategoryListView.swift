//
//  CategoryListView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 15/11/25.
//

import SwiftUI
import SwiftData


struct CategoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.createdAt, order: .reverse) private var categories: [Category]
    
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                expenseSection
                incomeSection
            }
            .navigationTitle("Danh mục")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Label("Thêm", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddCategoryView()
            }
        }
    }
}

extension CategoryListView {
    var expenseCategories: [Category] {
        categories.filter { $0.type == .expense }
    }
        
    var incomeCategories: [Category] {
        categories.filter { $0.type == .income }
    }
    
    private var expenseSection: some View {
        Section("Chi tiêu") {
            if expenseCategories.isEmpty {
                ContentUnavailableView("Trống", systemImage: "cart", description: Text("Chưa có danh mục chi tiêu"))
            } else {
                ForEach(categories.filter { $0.type == .expense }) { category in
                    CategoryRowView(category: category)
                }
                .onDelete(perform: deleteExpenses)
            }
        }
    }
    
    private var incomeSection: some View {
        Section("Thu nhập") {
            if incomeCategories.isEmpty {
                ContentUnavailableView("Trống", systemImage: "dollarsign.circle", description: Text("Chưa có danh mục thu nhập"))
            } else {
                ForEach(categories.filter{ $0.type == .income }) { category in
                    CategoryRowView(category: category)
                }
                .onDelete(perform: deleteIncomes)
            }
        }
    }
    
    private func deleteExpenses(_ offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let categoryToDelete = expenseCategories[index]
                modelContext.delete(categoryToDelete)
            }
        }
    }
    
    private func deleteIncomes(_ offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let categoryToDelete = incomeCategories[index]
                modelContext.delete(categoryToDelete)
            }
        }
    }
}

#Preview {
    CategoryListView()
        .modelContainer(PreviewContainer.shared)
}
