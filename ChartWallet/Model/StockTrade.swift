//
//  StockTrade.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import Foundation

struct StockTrade: Codable, Identifiable {
    let id = UUID()
    let symbol: String
    let price: Double
    let timestamp: Date
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
