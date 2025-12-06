//
//  CurrencyViewModel.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 06/12/25.
//

import Foundation
import Observation

@Observable
class CurrencyViewModel {
    private let service: CurrencyServiceProtocol
    
    var selectedCurrency: Currency = .vnd
    var foreignAmount: Double = 0
    var exchangeRate: Double = 0
    var lastUpdated: Date?
    var isLoading: Bool = false
    var errorMessage: String?
    var isManualRate: Bool = false
    
    var finalVNDAmount: Double {
        if selectedCurrency == .vnd {
            return foreignAmount
        }
        return foreignAmount * exchangeRate
    }
    
    init(service: CurrencyServiceProtocol = CurrencyService()) {
        self.service = service
    }
    
    @MainActor
    func fetchRate() async {
        guard selectedCurrency != .vnd else { return }
        
        if isManualRate && exchangeRate > 0 { return }
        
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let result = try await service.fetchRate(from: selectedCurrency.id, to: "VND")
            if !isManualRate {
                self.exchangeRate = result.rate
                self.lastUpdated = result.lastUpdated
                self.isManualRate = false
            }
        } catch {
            self.errorMessage = "Không lấy được tỷ giá. Vui lòng thử lại hoặc nhập thủ công"
            self.isManualRate = true
            if self.exchangeRate == 0 {
                self.exchangeRate = 1
            }
        }
    }
    
    func toggleManualRate() {
        isManualRate.toggle()
        
        if !isManualRate {
            Task { await fetchRate() }
        }
    }
        
    func resetToVND() {
        selectedCurrency = .vnd
        exchangeRate = 0
        lastUpdated = nil
        errorMessage = nil
        isManualRate = false
    }
}
