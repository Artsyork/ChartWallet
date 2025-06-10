//
//  PopularStocks_API.swift
//  ChartWallet
//
//  Created by DY on 6/9/25.
//

/// 인기 종목 데이터 API 
struct PopularStocks_API: Codable {
    
    static let endPoint = "https://financialmodelingprep.com/api/v3/actives"
    
    struct Request: Codable {
        let apikey: String
    }
    
    struct Response: Codable {
        /// 주식 심볼
        let symbol: String
        /// 회사명
        let name: String
        /// 가격 변동액
        let change: Double
        /// 현재 가격
        let price: Double
        /// 가격 변동률(%)
        let changesPercentage: Double
    }
    
    struct Path: Codable {
        
    }
    
}
