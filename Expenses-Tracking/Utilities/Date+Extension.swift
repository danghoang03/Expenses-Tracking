//
//  Date+Extension.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 24/11/25.
//

import Foundation

extension Date {
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    var startOfWeek: Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var startOfNextWeek: Date {
        calendar.date(byAdding: .day, value: 7, to: startOfWeek) ?? self
    }
    
    var startOfMonth: Date {
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var startOfNextMonth: Date {
        calendar.date(byAdding: .month, value: 1, to: startOfMonth) ?? self
    }
    
    var startOfYear: Date {
        let components = calendar.dateComponents([.year], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var startOfNextYear: Date {
        calendar.date(byAdding: .year, value: 1, to: startOfYear) ?? self
    }
}
