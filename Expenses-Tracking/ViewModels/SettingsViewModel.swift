//
//  SettingsViewModel.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 16/11/25.
//

import Observation
import SwiftUI

@Observable
class SettingsViewModel {
    enum Route: Hashable, CaseIterable {
        case wallets
        case categories
        
        var title: String {
            switch self {
            case .wallets: "Quản lý Ví"
            case .categories: "Quản lý Danh mục"
            }
        }
        
        var icon: String {
            switch self {
            case .wallets: "creditcard.fill"
            case .categories: "list.bullet.rectangle.portrait.fill"
            }
        }
    }
    
    var menuItems: [Route] = Route.allCases
}
