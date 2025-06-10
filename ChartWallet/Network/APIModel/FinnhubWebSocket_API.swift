//
//  FinnhubWebSocket_API.swift
//  ChartWallet
//
//  Created by DY on 6/9/25.
//

/// (WebSocket) 실시간 거래 데이터 API
struct FinnhubWebSocket_API: Codable {
    
    static let endPoint = "wss://ws.finnhub.io"
    
    struct Request: Codable {
        /// 메시지 타입 ("subscribe", "unsubscribe")
        let type: String
        /// 주식 심볼
        let symbol: String
        
        init(type: RequestType, symbol: String) {
            self.type = type.rawValue
            self.symbol = symbol
        }
    }
    
    struct Response: Codable {
        /// 거래 데이터 배열 (선택적)
        let data: [TradeData]?
        /// 메시지 타입 ("trade", "ping", "subscribe" 등)
        let type: String?
    }
    
    struct TradeData: Codable {
        /// 주식 심볼
        let s: String
        /// 거래 가격
        let p: Double
        /// 거래 시간 (milliseconds timestamp)
        let t: Int64
        /// 거래량 (선택적)
        let v: Int?
    }
    
    struct Path: Codable {
        /// WebSocket 연결용 토큰 (Query Parameter)
        let token: String
    }
    
    enum RequestType: String {
        case subscribe
        case unsubscribe
    }
}
