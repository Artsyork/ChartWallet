//
//  HoldingStock.swift
//  ChartWallet
//
//  Created by DY on 6/9/25.
//

import Foundation

/// 보유 주식 정보
struct HoldingStock: Identifiable, Codable {
    var id = UUID()
    /// 주식 심볼 (예: "AAPL", "GOOGL")
    let symbol: String
    let name: String
    /// 보유 수량 (소수점 가능)
    let quantity: Double
    /// 구매 가격
    let purchasePrice: Double
    /// 구매 날짜
    let purchaseDate: Date
    /// 현재 주가 (USD)
    var currentPrice: Double = 0.0
    var priceChange: Double = 0.0
    var priceChangePercent: Double = 0.0
    /// 주식 차트 정보
    var chartData: [StockTrade] = []
    /// 애널리스트 평가 정보
    var analystData: AnalystRecommendation?
    
    var totalValue: Double {
        return currentPrice * quantity
    }
    
    var totalCost: Double {
        return purchasePrice * quantity
    }
    
    var profitLoss: Double {
        return totalValue - totalCost
    }
    
    var profitLossPercent: Double {
        guard totalCost > 0 else { return 0 }
        return (profitLoss / totalCost) * 100
    }
    
    init(symbol: String, name: String, quantity: Double, purchasePrice: Double, purchaseDate: Date = Date()) {
        self.symbol = symbol
        self.name = name
        self.quantity = quantity
        self.purchasePrice = purchasePrice
        self.purchaseDate = purchaseDate
    }
    
    enum CodingKeys: String, CodingKey {
        case symbol, name, quantity, purchasePrice, purchaseDate
    }
}
