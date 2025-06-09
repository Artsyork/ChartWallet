//
//  StockItem.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import Foundation

struct StockItem: Identifiable {
    /// 고유 식별자 (UUID 자동 생성)
    let id = UUID()
    /// 주식 심볼 (예: "AAPL")
    let symbol: String
    /// 회사명 (예: "Apple Inc.")
    let name: String
    /// 현재 주가 (USD)
    var currentPrice: Double = 0.0
    /// 가격 변동액 (USD)
    var priceChange: Double = 0.0
    /// 가격 변동률 (%)
    var priceChangePercent: Double = 0.0
    /// 실시간 차트용 거래 데이터 배열
    var chartData: [StockTrade] = []
    /// 애널리스트 추천 데이터 (선택적)
    var analystData: AnalystRecommendation?
}
