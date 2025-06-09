//
//  AnalystRecommendation_API.swift
//  ChartWallet
//
//  Created by DY on 6/9/25.
//

/// 애널리스트 추천 정보 조회 API
struct AnalystRecommendation_API: Codable {
    
    static let endPoint = "https://financialmodelingprep.com/api/v3/analyst-stock-recommendations"
    
    struct Request: Codable {
        /// API 키
        let apikey: String
    }
    
    struct Response: Codable {
        /// 주식 심볼
        let symbol: String
        /// Strong Buy 추천 수
        let analystRatingsStrongBuy: Int?
        /// Buy 추천 수
        let analystRatingsBuy: Int?
        /// Hold 추천 수
        let analystRatingsHold: Int?
        /// Sell 추천 수
        let analystRatingsSell: Int?
        /// Strong Sell 추천 수
        let analystRatingsStrongSell: Int?
        /// 평균 목표가 (USD)
        let analystTargetPrice: Double?
        /// 최고 목표가 (USD)
        let analystTargetPriceHigh: Double?
        /// 최저 목표가 (USD)
        let analystTargetPriceLow: Double?
    }
    
    struct Path: Codable {
        /// 주식 심볼 (URL 경로에 포함)
        let symbol: String
    }
}
