//
//  StockTrade.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import Foundation

struct StockTrade: Codable, Identifiable {
    /// 고유 식별자 (UUID 자동 생성)
    let id = UUID()
    /// 주식 심볼 (예: "AAPL", "GOOGL")
    let symbol: String
    /// 거래 가격 (USD)
    let price: Double
    /// 거래 발생 시간
    let timestamp: Date
    /// 거래량 (선택적)
    let volume: Int?
    
    enum CodingKeys: String, CodingKey {
        case symbol = "s"
        case price = "p"
        case timestamp = "t"
        case volume = "v"
    }
    
    init(symbol: String, price: Double, timestamp: Date, volume: Int?) {
        self.symbol = symbol
        self.price = price
        self.timestamp = timestamp
        self.volume = volume
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(String.self, forKey: .symbol)
        price = try container.decode(Double.self, forKey: .price)
        volume = try container.decodeIfPresent(Int.self, forKey: .volume)
        
        let timestampMillis = try container.decode(Int64.self, forKey: .timestamp)
        timestamp = Date(timeIntervalSince1970: TimeInterval(timestampMillis) / 1000.0)
    }
    
}
