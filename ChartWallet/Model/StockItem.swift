//
//  StockItem.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import Foundation

struct StockItem: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    var currentPrice: Double = 0.0
    var priceChange: Double = 0.0
    var priceChangePercent: Double = 0.0
    var chartData: [StockTrade] = []
    var analystData: AnalystRecommendation?
}
