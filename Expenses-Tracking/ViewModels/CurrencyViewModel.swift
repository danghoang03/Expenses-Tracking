//
//  CurrencyViewModel.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 06/12/25.
//

import Foundation
import Observation

/// Manages currency conversion logic and state.
@Observable
class CurrencyViewModel {
    private let service: CurrencyServiceProtocol
    
    /// The currently selected foreign currency. Defaults to VND (Local).
    var selectedCurrency: Currency = .vnd
    /// The amount entered in the foreign currency.
    var foreignAmount: Double = 0
    /// The current exchange rate (1 Unit of Foreign Currency = X VND).
    var exchangeRate: Double = 0
    /// Timestamp of the last successful rate fetch.
    var lastUpdated: Date?
    /// Indicates if a network request is in progress.
    var isLoading: Bool = false
    /// Stores error messages from the API service.
    var errorMessage: String?
    /// Flag indicating if the user is manually overriding the exchange rate.
    var isManualRate: Bool = false
    
    /// The calculated amount in VND.
    /// Returns `foreignAmount` directly if currency is VND, otherwise `foreignAmount * exchangeRate`.
    var finalVNDAmount: Double {
        if selectedCurrency == .vnd {
            return foreignAmount
        }
        return foreignAmount * exchangeRate
    }
    
    init(service: CurrencyServiceProtocol = CurrencyService()) {
        self.service = service
    }
    
    /// Fetches the latest exchange rate from the service.
    ///
    /// Skips fetching if the selected currency is VND or if the user is in manual rate mode.
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
