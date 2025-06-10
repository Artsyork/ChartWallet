//
//  AnalystGradeSummary_API.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

/// 애널리스트 등급 요약 API (무료 플랜에서 사용 가능)
struct AnalystGradeSummary_API: Codable {
    
    static let endPoint = "https://financialmodelingprep.com/api/v4/grade-summary"
    
    struct Request: Codable {
        /// 주식 심볼
        let symbol: String
        /// API 키
        let apikey: String
    }
    
    struct Response: Codable {
        /// 주식 심볼
        let symbol: String
        /// Strong Buy 개수
        let strongBuy: Int?
        /// Buy 개수
        let buy: Int?
        /// Hold 개수
        let hold: Int?
        /// Sell 개수
        let sell: Int?
        /// Strong Sell 개수
        let strongSell: Int?
        /// 평균 목표가
        let avgPriceTarget: Double?
        /// 최고 목표가
        let highPriceTarget: Double?
        /// 최저 목표가
        let lowPriceTarget: Double?
    }
    
    struct Path: Codable {
        /// 주식 심볼 (URL 경로에 포함)
        let symbol: String
    }
}
