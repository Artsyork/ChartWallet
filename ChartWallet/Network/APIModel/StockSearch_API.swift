//
//  StockSearch_API.swift
//  ChartWallet
//
//  Created by DY on 6/9/25.
//

/// 주식 검색 데이터 API
struct StockSearch_API: Codable {
    
    static let endPoint = "https://financialmodelingprep.com/api/v3/search"
    
    struct Request: Codable {
        /// 검색 키워드 (회사명 또는 심볼)
        let query: String
        /// 검색 결과 개수 제한
        let limit: Int
        /// FMP API 키
        let apikey: String
    }
    
    struct Response: Codable {
        /// 주식 심볼 (예: "AAPL")
        let symbol: String
        /// 회사명 (예: "Apple Inc.")
        let name: String
        /// 통화 (예: "USD")
        let currency: String?
        /// 거래소 전체명 (예: "NASDAQ Global Select")
        let stockExchange: String?
        /// 거래소 축약명 (예: "NASDAQ")
        let exchangeShortName: String?
    }
    
    struct Path: Codable {
        
    }
    
}
