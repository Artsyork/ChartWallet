//
//  FinnhubQuote_API.swift
//  ChartWallet
//
//  Created by DY on 6/9/25.
//

/// (WebSocket) 주식 실시간 시세 조회 API
struct FinnhubQuote_API: Codable {
    
    static let endPoint = "https://finnhub.io/api/v1/quote"
    
    struct Request: Codable {
        /// 주식 심볼 (예: "AAPL")
        let symbol: String
        /// API 토큰
        let token: String
    }
    
    struct Response: Codable {
        /// 현재 가격 (Current price)
        let c: Double
        /// 가격 변동액 (Change)
        let d: Double
        /// 가격 변동률 (Percent change)
        let dp: Double
        /// 당일 최고가 (High price of the day)
        let h: Double
        /// 당일 최저가 (Low price of the day)
        let l: Double
        /// 시가 (Open price of the day)
        let o: Double
        /// 전일 종가 (Previous close price)
        let pc: Double
    }
    
    struct Path: Codable {
        
    }
}
