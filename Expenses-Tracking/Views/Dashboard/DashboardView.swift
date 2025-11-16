//
//  DashboardView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 16/11/25.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        ContentUnavailableView(
            "Dashboard",
            systemImage: "house.circle",
            description: Text("Tính năng này đang trong quá trình phát triển")
        )
        .navigationTitle("Tổng quan")
    }
}

#Preview {
    DashboardView()
}
