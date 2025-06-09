//
//  StockQuote.swift
//  ChartWallet
//
//  Created by DY on 6/9/25.
//

struct StockQuote {
    /// 주식 심볼 (예: "AAPL", "GOOGL")
    let symbol: String
    /// 현재 주가 (USD)
    let currentPrice: Double
    /// 가격 변동액 (USD, 전일 대비)
    let change: Double
    /// 가격 변동률 (%, 전일 대비)
    let changePercent: Double
}
