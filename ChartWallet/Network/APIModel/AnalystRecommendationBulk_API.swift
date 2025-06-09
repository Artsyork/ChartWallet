//
//  AnalystRecommendationBulk_API.swift
//  ChartWallet
//
//  Created by DY on 6/9/25.
//

struct AnalystRecommendationBulk_API: Codable {
    static let endPoint = "https://financialmodelingprep.com/api/v4/upgrades-downgrades-consensus-bulk"
    
    struct Request: Codable {
        let apikey: String
    }
    
    struct Response: Codable {
        let symbol: String
        let consensusRating: String?
        let strongBuy: Int?
        let buy: Int?
        let hold: Int?
        let sell: Int?
        let strongSell: Int?
        let avgPriceTarget: Double?
        let highPriceTarget: Double?
        let lowPriceTarget: Double?
    }
    
    struct Path: Codable {
        // Bulk API는 별도 path가 필요없음
    }
}
