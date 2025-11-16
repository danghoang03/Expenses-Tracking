//
//  TransactionListView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 16/11/25.
//

import SwiftUI

struct TransactionListView: View {
    var body: some View {
        ContentUnavailableView(
            "Sổ giao dịch",
            systemImage: "doc.text.magnifyingglass",
            description: Text("Tính năng này đang trong quá trình phát triển")
        )
        .navigationTitle("Lịch sử")
    }
}

#Preview {
    TransactionListView()
}
