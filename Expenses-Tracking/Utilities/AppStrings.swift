//
//  AppStrings.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 17/12/25.
//

import Foundation
import SwiftUI

struct AppStrings {
    
    struct General {
        static let cancel = String(localized: "Huỷ")
        static let save = String(localized: "Lưu")
        static let delete = String(localized: "Xóa")
        static let add = String(localized: "Thêm")
        static let done = String(localized: "Xong")
        static let edit = String(localized: "Sửa")
        static let ok = String(localized: "OK")
        static let searchPrompt = String(localized: "Tìm kiếm...")
        static let empty = String(localized: "Trống")
        static let currencyVND = "VND"
    }
    
    struct Dashboard {
        static let title = String(localized: "Tổng quan")
        static let totalBalance = String(localized: "Tổng tài sản")
        static let monthlyIncome = String(localized: "Thu nhập tháng này")
        static let monthlyExpense = String(localized: "Chi tiêu tháng này")
        static let myWallets = String(localized: "Ví của tôi")
        static let recentTransactions = String(localized: "Giao dịch gần đây")
        static let noTransactionTitle = String(localized: "Chưa có giao dịch")
        static let noTransactionDesc = String(localized: "Chọn + để thêm giao dịch đầu tiên.")
    }
    
    struct Transaction {
        static let income = String(localized: "Thu nhập")
        static let expense = String(localized: "Chi tiêu")
        static let transfer = String(localized: "Chuyển khoản")
        static let listTitle = String(localized: "Sổ giao dịch")
        static let detailTitle = String(localized: "Chi tiết giao dịch")
        static let addTitle = String(localized: "Giao dịch mới")
        static let editTitle = String(localized: "Sửa giao dịch")
        static let date = String(localized: "Ngày giao dịch")
        static let day = String(localized: "Ngày")
        static let hour = String(localized: "Giờ")
        static let notePlaceholder = String(localized: "Ghi chú (VD: Ăn sáng)")
        static let note = String(localized: "Ghi chú")
        static let category = String(localized: "Danh mục")
        static let noCategory = String(localized: "Không có danh mục")
        static let noCategoryTitle = String(localized: "Chưa có danh mục")
        static let noCategoryDesc = String(localized: "Vui lòng tạo danh mục ở phần Cài đặt.")
        static let selectCategory = String(localized: "Chọn danh mục")
        static let walletHeader = String(localized: "Tài khoản / Ví")
        static let noWallet = String(localized: "Chưa có ví, vui lòng tạo ví ở phần Cài đặt")
        static let incomeToWallet = String(localized: "Vào ví")
        static let fromWallet = String(localized: "Từ ví")
        static let toWallet = String(localized: "Đến ví")
        static let deleteConfirm = String(localized: "Bạn có chắc chắn muốn xóa giao dịch này không?")
        static let deleteButton = String(localized: "Xoá giao dịch")
        static let insufficientFundTitle = String(localized: "Số dư không đủ")
        static let insufficientFundMsg = String(localized: "Số dư của bạn hiện không đủ, vui lòng kiểm tra lại giao dịch.")
        static let noTransactionDesc = String(localized: "Các chi tiêu thuộc danh mục này sẽ xuất hiện tại đây.")
        static let currencyTitle = String(localized: "Số tiền & Loại tiền")
        static let currencyType = String(localized: "Loại tiền")
        static let exchangeRate = String(localized: "Tỷ giá")
        static let useAPI = String(localized: "Lấy tỷ giá")
        static let manual = String(localized: "Nhập thủ công")
        static let resultVND = String(localized: "Thành tiền VND")
        static let cashFlow = String(localized: "Dòng tiền")
        static let byTime = String(localized: "Theo thời gian")
        static let all = String(localized: "Tất cả")
        static let byWallet = String(localized: "Theo ví")
        static let byType = String(localized: "Theo loại giao dịch")
        static let byCategory = String(localized: "Theo danh mục")
        static let reduce = String(localized: "Thu gọn")
        static let expand = String(localized: "Xem thêm")
        static let deleteFilter = String(localized: "Xoá bộ lọc")
        static let apply = String(localized: "Áp dụng")
        static let noTransactionDescription = String(localized: "Hãy tạo giao dịch đầu tiên của bạn ngay bây giờ.")
        static let noResultFoundTitle = String(localized: "Không tìm thấy kết quả")
        static let noResultFoundDesc = String(localized: "Thử thay đổi hoặc xoá bộ lọc để xem thêm kết quả.")
        static let emptySearchDesc = String(localized: "Hãy thử tìm kiếm lại với từ khóa khác")
        static let appliedFilter = String(localized: "Đã áp dụng bộ lọc")
    }
    
    struct Category {
        static let addTitle = String(localized: "Tạo danh mục")
        static let info = String(localized: "Thông tin")
        static let name = String(localized: "Tên danh mục")
        static let type = String(localized: "Loại")
        static let interface = String(localized: "Giao diện")
        static let color = String(localized: "Màu sắc")
        static let noExpenseCategory = String(localized: "Chưa có danh mục chi tiêu")
        static let noIncomeCategory = String(localized: "Chưa có danh mục thu nhập")
        static let system = String(localized: "Hệ thống")
    }
    
    struct Budget {
        static let title = String(localized: "Ngân sách")
        static let listTitle = String(localized: "Ngân sách tháng này")
        static let addTitle = String(localized: "Tạo ngân sách")
        static let editTitle = String(localized: "Sửa ngân sách")
        static let noAvailableCategoriesTitle = String(localized: "Không còn danh mục khả dụng")
        static let noAvailableCategoriesDesc = String(localized: "Tất cả danh mục chi tiêu đều đã có ngân sách.")
        static let spent = String(localized: "Đã chi")
        static let remaining = String(localized: "Còn lại")
        static let limit = String(localized: "Hạn mức")
        static let budgetNote = String(localized: "Ngân sách sẽ áp dụng cho tháng hiện tại và được tính toán dựa trên các giao dịch chi tiêu.")
        static let detailBudget = String(localized: "Chi tiết ngân sách")
        static let suggestion = String(localized: "Gợi ý chi tiêu")
        static let noBudget = String(localized: "Chưa có ngân sách")
        static let deleteBudgetAlertTitle = String(localized: "Xóa ngân sách")
        static let deleteBudgetAlertMsg = String(localized: "Bạn có chắc chắn muốn xóa ngân sách này không? Dữ liệu giao dịch sẽ không bị ảnh hưởng.")
        static let noBudgetDesc = String(localized: "Đặt giới hạn chi tiêu giúp bạn kiểm soát tài chính tốt hơn.")
        static let used = String(localized: "Đã dùng")
        static let relevantTransactionsThisMonth = String(localized: "Giao dịch liên quan tháng này")
        static let creatBudgetNow = String(localized: "Tạo ngân sách ngay")
    }
        
    struct Wallet {
        static let listTitle = String(localized: "Ví của tôi")
        static let addTitle = String(localized: "Thêm Ví Mới")
        static let delete = String(localized: "Xoá ví")
        static let namePlaceholder = String(localized: "Tên ví (VD: Tiền mặt)")
        static let initialBalance = String(localized: "Số dư ban đầu")
        static let currentBalance = String(localized: "Số dư")
        static let deleteButton = String(localized: "Xóa ví")
        static let basicInfo = String(localized: "Thông tin cơ bản")
        static let icon = String(localized: "Biểu tượng")
        static let noWalletTitle = String(localized: "Chưa có ví nào")
        static let noWalletDesc = String(localized: "Hãy tạo ví để theo dõi dòng tiền")
    }
    
    struct Report {
        static let title = String(localized: "Báo cáo")
        static let total = String(localized: "Tổng chi tiêu")
        static let expenseTrend = String(localized: "Xu hướng chi tiêu")
        static let vndUnit = String(localized: "Đơn vị: VNĐ")
        static let noData = String(localized: "Chưa có dữ liệu")
        static let noDataDesc = String(localized: "Hãy thêm giao dịch chi tiêu để xem xu hướng chi tiêu.")
        static let average = String(localized: "Trung bình")
        static let expenseStructure = String(localized: "Cơ cấu chi tiêu")
        static let amount = String(localized: "Số tiền")
        static let noDataDonutDesc = String(localized: "Hãy thêm giao dịch chi tiêu để xem biểu đồ phân tích.")
    }
        
    struct Settings {
        static let title = String(localized: "Cài đặt")
        static let sourceData = String(localized: "Dữ liệu nguồn")
        static let notification = String(localized: "Thông báo")
        static let dailyReminder = String(localized: "Nhắc nhở hàng ngày")
        static let time = String(localized: "Thời gian")
        static let dataBackup = String(localized: "Dữ liệu & Sao lưu")
        static let exportCSV = String(localized: "Xuất file CSV")
        static let exporting = String(localized: "Đang xuất dữ liệu...")
        static let appInfo = String(localized: "Ứng dụng")
        static let version = String(localized: "Phiên bản")
        static let manageWallets = String(localized: "Quản lý Ví")
        static let manageCategories = String(localized: "Quản lý Danh mục")
        static let authorizationAlertTitle = String(localized: "Cấp quyền thông báo")
        static let authorizationAlertMsg = String(localized: "Ứng dụng cần quyền thông báo để nhắc nhở bạn. Vui lòng bật trong Cài đặt.")
    }
}
