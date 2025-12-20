//
//  CurrencyService.swift
//  Expenses-Tracking
//
//  Created by Hoàng Minh Hải Đăng on 06/12/25.
//

import Foundation

struct Currency: Identifiable, Hashable, CaseIterable {
    let id: String
    let name: String
    let flag: String
    
    static let vnd = Currency(id: "VND", name: "VND", flag: "🇻🇳")
    static let usd = Currency(id:"USD", name: "USD", flag: "🇺🇸")
    static let eur = Currency(id: "EUR", name: "EUR", flag: "🇪🇺")
    static let jpy = Currency(id: "JPY", name: "JPY", flag: "🇯🇵")
    static let krw = Currency(id: "KRW", name: "KRW", flag: "🇰🇷")
    static let cny = Currency(id: "CNY", name: "CNY", flag: "🇨🇳")
    
    static var allCases: [Currency] { [.vnd, .usd, .eur, .jpy, .krw, .cny] }
}

struct ExchangeRateResponse: Codable {
    let base_code: String
    let conversion_rates: [String: Double]
    let time_last_update_unix: TimeInterval
}

/// A service responsible for fetching and caching currency exchange rates.
///
/// This service connects to the ExchangeRate - API to retrieve the latest rates.
/// It implements a caching mechanism using `UserDefaults` to minimize network calls and API usage.
protocol CurrencyServiceProtocol {
    /// Fetches the exchange rate between two currencies.
    ///
    /// - Parameters:
    ///    - source: The currency code to convert from (e.g.  "VND").
    ///    - target: The currency code to convert to (e.g. "USD).
    /// - Returns: A tuple containing the `rate` (Double) and the `lastUpdated` (Date) timestamp.
    /// - Throws: `URLError` if the network request fails or decoding errors if the API response is invalid
    func fetchRate(from source: String, to target: String) async throws -> (rate: Double, lastUpdated: Date)
}

/// The concrete implementation of `CurrencyServiceProtocol`.
struct CurrencyService: CurrencyServiceProtocol {
    private let session: URLSession
    private let defaults: UserDefaults
    
    private let cacheValidityDuration: TimeInterval = 86400
    
    private var APIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "ExchangeRateAPIKey") as? String else {
            print("Error: The API Key has not been configured in Secrets.xcconfig.")
            return ""
        }
        return key
    }
    
    init(session: URLSession = .shared, defaults: UserDefaults = .standard) {
        self.session = session
        self.defaults = defaults
    }
    
    /// Fetches the exchange rate from the API or local cache.
    ///
    /// **Caching Strategy:**
    /// 1.  Checks `UserDefaults` for a saved rate using the key `CurrencyRate_{source}_{target}`.
    /// 2. Verifies if the cached data is fresh (less than `cacheValidityDuration` = 24 hours).
    /// 3. If valid, returns the cached rate immediately (Offline-first approach).
    /// 4. If expired or missing, executes a network request to `exchangerate-api.com`.
    /// 5. On success, updates the cache with the new rate and timestamp.
    ///
    ///  - Parameters:
    ///     - source: The 3-letter currency code (ISO 4217) for the source currency.
    ///     - target: The 3-letter currency code (ISO 4217) for the target currency.
    ///  - Returns: The conversion rate and the timestamp of the data.
    ///  - Throws: `URLError.badURL` if the API key is missing or URL is invalid.
    ///  - Throws: `URLError.badServerResponse` if the API returns a non-200 status code.
    func fetchRate(from source: String, to target: String) async throws -> (rate: Double, lastUpdated: Date) {
        let rateKey = "CurrencyRate_\(source)_\(target)"
        let dateKey = "CurrencyDate_\(source)_\(target)"
        
        if let savedDate = defaults.object(forKey: dateKey) as? Date,
           let savedRate = defaults.object(forKey: rateKey) as? Double {
            let timeElapsed = Date().timeIntervalSince(savedDate)
            
            if timeElapsed < cacheValidityDuration {
                return (savedRate, savedDate)
            }
        }
         
        guard let url = URL(string: "https://v6.exchangerate-api.com/v6/\(APIKey)/latest/\(source)") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
        
        guard let rate = decoded.conversion_rates[target] else {
            throw URLError(.cannotParseResponse)
        }
        
        let date = Date(timeIntervalSince1970: decoded.time_last_update_unix)
        
        defaults.set(rate, forKey: rateKey)
        defaults.set(date, forKey: dateKey)
        
        return (rate, date)
    }
}

struct MockCurrencyService: CurrencyServiceProtocol {
    func fetchRate(from source: String, to target: String) async throws -> (rate: Double, lastUpdated: Date) {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        if source == "USD" && target == "VND" { return (26500, Date()) }
        else if source == "EUR" && target == "USD" { return (30500, Date()) }
        else if source == "JPY" && target == "VND" { return (170, Date()) }
        else if source == "KRW" && target == "VND" { return (18, Date()) }
        else if source == "CNY" && target == "VND" { return (3700, Date()) }
        return (1, Date())
    }
}
