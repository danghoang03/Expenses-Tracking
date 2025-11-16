//
//  ReportView.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 16/11/25.
//

import SwiftUI

struct ReportView: View {
    var body: some View {
        ContentUnavailableView(
            "Báo cáo thống kê",
            systemImage: "chart.xyaxis.line",
            description: Text("Tính năng này đang trong quá trình phát triển")
        )
        .navigationTitle("Báo cáo")
    }
}

#Preview {
    ReportView()
}
