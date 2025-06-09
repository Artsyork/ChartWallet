//
//  AnalystRecommendation.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUICore

struct AnalystRecommendation: Codable {
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
    
    // Bulk API Response에서 변환하는 생성자 추가
    init(from bulkResponse: AnalystRecommendationBulk_API.Response) {
        self.symbol = bulkResponse.symbol
        self.analystRatingsStrongBuy = bulkResponse.strongBuy
        self.analystRatingsBuy = bulkResponse.buy
        self.analystRatingsHold = bulkResponse.hold
        self.analystRatingsSell = bulkResponse.sell
        self.analystRatingsStrongSell = bulkResponse.strongSell
        self.analystTargetPrice = bulkResponse.avgPriceTarget
        self.analystTargetPriceHigh = bulkResponse.highPriceTarget
        self.analystTargetPriceLow = bulkResponse.lowPriceTarget
    }
    
    // 기존 생성자 유지
    init(symbol: String, analystRatingsStrongBuy: Int?, analystRatingsBuy: Int?, analystRatingsHold: Int?, analystRatingsSell: Int?, analystRatingsStrongSell: Int?, analystTargetPrice: Double?, analystTargetPriceHigh: Double?, analystTargetPriceLow: Double?) {
        self.symbol = symbol
        self.analystRatingsStrongBuy = analystRatingsStrongBuy
        self.analystRatingsBuy = analystRatingsBuy
        self.analystRatingsHold = analystRatingsHold
        self.analystRatingsSell = analystRatingsSell
        self.analystRatingsStrongSell = analystRatingsStrongSell
        self.analystTargetPrice = analystTargetPrice
        self.analystTargetPriceHigh = analystTargetPriceHigh
        self.analystTargetPriceLow = analystTargetPriceLow
    }
    
    var averageRating: BuyComment {
        let strong = analystRatingsStrongBuy ?? 0
        let buy = analystRatingsBuy ?? 0
        let hold = analystRatingsHold ?? 0
        let sell = analystRatingsSell ?? 0
        let strongSell = analystRatingsStrongSell ?? 0
        
        let total = strong + buy + hold + sell + strongSell
        guard total > 0 else { return .none }
        
        let weightedScore = (strong * 5 + buy * 4 + hold * 3 + sell * 2 + strongSell * 1)
        let average = Double(weightedScore) / Double(total)
        
        return BuyComment.create(average: average)
    }
    
    var targetPriceUpside: Double? {
        guard let targetPrice = analystTargetPrice else { return nil }
        return targetPrice
    }
}

enum BuyComment: String {
    case veryGood = "적극 구매"
    case good = "구매"
    case stay = "유지"
    case sell = "판매"
    case verySell = "적극 판매"
    case none = "N/A"
    
    static func create(average: Double) -> Self {
        switch average {
        case 4.5...5.0: return .veryGood
        case 3.5..<4.5: return .good
        case 2.5..<3.5: return .stay
        case 1.5..<2.5: return .sell
        default: return .verySell
        }
    }
    
    var color: Color {
        switch self {
        case .veryGood: return .green
        case .good: return .mint
        case .stay: return .yellow
        case .sell: return .orange
        case .verySell: return .red
        case .none: return .secondary
        }
    }
}
