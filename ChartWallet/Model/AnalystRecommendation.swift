//
//  AnalystRecommendation.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUICore

struct AnalystRecommendation: Codable {
    let symbol: String
    let analystRatingsStrongBuy: Int?
    let analystRatingsBuy: Int?
    let analystRatingsHold: Int?
    let analystRatingsSell: Int?
    let analystRatingsStrongSell: Int?
    let analystTargetPrice: Double?
    let analystTargetPriceHigh: Double?
    let analystTargetPriceLow: Double?
    
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
