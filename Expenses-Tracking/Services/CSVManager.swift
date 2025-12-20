//
//  CSVManager.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 12/12/25.
//

import Foundation

/// A utility for exporting app data to CSV format.
struct CSVManager {
    
    /// Generates a CSV file URL from a list of transactions.
    ///
    /// This method formates `Transaction` objects into a comma-seperated string suitable for spreadsheet software (Excel, Numbers, etc.).
    ///
    /// **Character Encoding:**
    /// It prepends a **UTF-8 BOM (Byte Order Mark)** (`0xEF, 0xBB, 0xBF`) to the file content.
    /// This ensures that Microsoft Excel correctly recognizes special characters (like Vietnamese accents) when opening the file.
    ///
    /// - Parameter transactions: An array of `Transaction` objects to export.
    /// - Returns: A temporary `URL` pointing to the generated `.csv` file, or `nil` if writing fails.
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
