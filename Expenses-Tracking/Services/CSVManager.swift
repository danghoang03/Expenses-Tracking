//
//  CSVManager.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 12/12/25.
//

import Foundation


struct CSVManager {
    
    static func generateCSV(from transactions: [Transaction]) -> URL? {
        // name of columns
        var csvString = "Ngày,Giờ,Số tiền,Loại,Danh mục,Ví,Ghi chú\n"
        
        for transaction in transactions {
            let date = transaction.createdAt.formatted(date: .numeric, time: .omitted)
            let time = transaction.createdAt.formatted(date: .omitted, time: .shortened)
            
            var amountPrefix = ""
            if let type = transaction.category?.type {
                switch type {
                case .expense: amountPrefix = "-"
                case .income: amountPrefix = "+"
                case .transfer: amountPrefix = ""
                }
            }
            let amount = "\(amountPrefix)\(Int(transaction.amount))"
            
            let typeName = transaction.category?.type.title ?? "Khác"
            let categoryName = transaction.category?.name ?? "Không có danh mục"
            let walletName = transaction.wallet?.name ?? "Không có ví"
            
            var note = transaction.note ?? ""
            if note.contains(",") || note.contains("\n") {
                note = "\"\(note)\""
            }
            
            let line = "\(date),\(time),\(amount),\(typeName),\(categoryName),\(walletName),\(note)\n"
            csvString.append(line)
        }
        
        let fileName = "Expenses_Export_\(Date().formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-")).csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            var content = Data()
            
            // Add UTF-8 BOM to ensure Microsoft Excel correctly recognizes Vietnamese characters
            let bom = [UInt8](arrayLiteral: 0xEF, 0xBB, 0xBF)
            content.append(contentsOf: bom)
            
            if let data = csvString.data(using: .utf8) {
                content.append(data)
                try content.write(to: path)
                return path
            }
            
            return nil
        } catch {
            print("Error creating CSV file: \(error)")
            return nil
        }
    }
}
