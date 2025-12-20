//
//  CurrencyServiceTest.swift
//  Expenses-TrackingTests
//
//  Created by Hoàng Minh Hải Đăng on 20/12/25.
//

import XCTest
@testable import Expenses_Tracking

final class CurrencyServiceTest: XCTestCase {
    
    var service: CurrencyService!
    var session: URLSession!
    var mockDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        // Configure URLSession to use MockURLProtocol
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration)
        
        // Create a isolated UserDefaults for testing
        mockDefaults = UserDefaults(suiteName: "TestDefaults")
        mockDefaults.removePersistentDomain(forName: "TestDefaults")
        
        service = CurrencyService(session: session, defaults: mockDefaults)
    }
    
    override func tearDown() {
        service = nil
        session = nil
        mockDefaults.removePersistentDomain(forName: "TestDefaults")
        mockDefaults = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    // Test Case 1: Fetch Rate Success
    // Verifies that the service correctly parses the API response when there is no cache.
    func testFetchRate_Success() async throws {
        // 1. Arrange: Setup mockup data
        let jsonString = """
        {
            "base_code": "USD",
            "time_last_update_unix": 1700000000,
            "conversion_rates": {
                "VND": 26800.5
            }
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        // 2. Act
        let result = try await service.fetchRate(from: "USD", to: "VND")
        
        // 3. Assert
        XCTAssertEqual(result.rate, 26800.5, "The parsing rate must be accurate")
    }
    
    // Test Case 2: Fetch Rate Failure (404)
    // Verifies that the service throws an error when the API returns a 404 status.
    func testFetchRate_Failure_BadResponse() async {
        // 1. Arrange: Simulate server error 404
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
                return (response, nil)
        }
            
        // 2. Act & Assert
        do {
            _ = try await service.fetchRate(from: "USD", to: "VND")
            XCTFail("This function must throw error when server return 404")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    // Test Case 3: Returns Cached Data (Valid Cache)
    // Verifies that the service returns data from UserDefaults without calling the API if cache is fresh (< 24h).
    func testFetchRate_ReturnsCachedData_WhenCacheIsValid() async throws {
        // 1. Arrange: Simulate existing valid cache (saved 1 hour ago)
        let source = "USD"
        let target = "VND"
        let cachedRate = 25000.0
        let recentDate = Date().addingTimeInterval(-3600) // 1 hour ago
            
        mockDefaults.set(cachedRate, forKey: "CurrencyRate_\(source)_\(target)")
        mockDefaults.set(recentDate, forKey: "CurrencyDate_\(source)_\(target)")
            
        // Configure Network Mock to FAIL if called.
        // If the service hits the network, the test will fail immediately.
        MockURLProtocol.requestHandler = { request in
            XCTFail("Network request should NOT be made when cache is valid")
            throw URLError(.cancelled)
        }
            
        // 2. Act
        let result = try await service.fetchRate(from: source, to: target)
            
        // 3. Assert
        XCTAssertEqual(result.rate, cachedRate, "Service should return the cached rate")
        XCTAssertEqual(result.lastUpdated, recentDate, "Service should return the cached timestamp")
    }
        
    // Test Case 4: Calls Network (Expired Cache)
    // Verifies that the service ignores expired cache (> 24h) and fetches fresh data from the API.
    func testFetchRate_CallsNetwork_WhenCacheIsExpired() async throws {
        // 1. Arrange: Simulate expired cache (saved 25 hours ago)
        let source = "USD"
        let target = "VND"
        let expiredDate = Date().addingTimeInterval(-90000) // > 24 hours
            
        mockDefaults.set(20000.0, forKey: "CurrencyRate_\(source)_\(target)")
        mockDefaults.set(expiredDate, forKey: "CurrencyDate_\(source)_\(target)")
        
        // Prepare new network data
        let newRate = 26000.0
        let jsonString = """
        {
            "base_code": "\(source)",
            "time_last_update_unix": \(Date().timeIntervalSince1970),
            "conversion_rates": { "\(target)": \(newRate) }
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
            
        // 2. Act
        let result = try await service.fetchRate(from: source, to: target)
            
        // 3. Assert
        XCTAssertEqual(result.rate, newRate, "Service should return the new rate from network, ignoring expired cache")
            
        // Verify cache is updated in UserDefaults
        let updatedRateInCache = mockDefaults.double(forKey: "CurrencyRate_\(source)_\(target)")
        XCTAssertEqual(updatedRateInCache, newRate, "UserDefaults should be updated with the new rate")
    }
}
