//
//  Color+Extension.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 14/11/25.
//

import SwiftUI

/// Extensions allowing `Color` initialization from Hex strings.
///
/// Since SwiftData cannot store `Color` objects directly, these extensions are critical
/// for converting UI colors to Hex strings for storage and converting them back for display.
extension Color {
    /// Initializes a Color from a HEX string.
    ///
    /// Supported formats:
    /// - `#RRGGBB` (e.g. "#FF0000")
    /// - `RRGGBB` (e.g. "FF0000")
    ///
    /// - Parameter hex: The hexadecimal string representation of the color.
    init(hex: String) {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleanHex.hasPrefix("#") {
            cleanHex.remove(at: cleanHex.startIndex)
        }
        
        var rgb: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&rgb)
        
        let redValue = Double((rgb >> 16) & 0xFF) / 255.0
        let greenValue = Double((rgb >> 8) & 0xFF) / 255.0
        let blueValue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: redValue, green: greenValue, blue: blueValue)
    }
    
    /// Converts the Color to a HEX string.
    ///
    /// - Returns: A string in the format `#RRGGBB` (e.g. "#2ECC71").
    ///            Returns `#000000` (Black) if conversion fails.
    func toHex() -> String {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}
