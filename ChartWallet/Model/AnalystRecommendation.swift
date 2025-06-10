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
    
    // MARK: - Initializers
    
    /// 기본 생성자
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
    
    /// Grade Summary API Response에서 변환하는 생성자 (새로 추가)
    init(from gradeSummaryResponse: AnalystGradeSummary_API.Response) {
        self.symbol = gradeSummaryResponse.symbol
        self.analystRatingsStrongBuy = gradeSummaryResponse.strongBuy
        self.analystRatingsBuy = gradeSummaryResponse.buy
        self.analystRatingsHold = gradeSummaryResponse.hold
        self.analystRatingsSell = gradeSummaryResponse.sell
        self.analystRatingsStrongSell = gradeSummaryResponse.strongSell
        self.analystTargetPrice = gradeSummaryResponse.avgPriceTarget
        self.analystTargetPriceHigh = gradeSummaryResponse.highPriceTarget
        self.analystTargetPriceLow = gradeSummaryResponse.lowPriceTarget
    }
    
    /// Grade API Response에서 변환하는 생성자 (fallback용 - 무료 플랜)
    init(from gradeResponse: AnalystRecommendation_API.Response, symbol: String) {
        self.symbol = symbol
        
        // newGrade 정보를 분석해서 등급 분포 결정
        var strongBuy: Int? = nil
        var buy: Int? = nil
        var hold: Int? = nil
        var sell: Int? = nil
        var strongSell: Int? = nil
        
        if let newGrade = gradeResponse.newGrade {
            // 등급 문자열을 분석해서 해당하는 등급에 1 할당
            let grade = newGrade.lowercased()
            switch grade {
            case let g where g.contains("strong buy") || g.contains("conviction buy"):
                strongBuy = 1
            case let g where g.contains("buy") || g.contains("outperform"):
                buy = 1
            case let g where g.contains("hold") || g.contains("neutral"):
                hold = 1
            case let g where g.contains("sell") || g.contains("underperform"):
                sell = 1
            case let g where g.contains("strong sell"):
                strongSell = 1
            default:
                hold = 1 // 기본값
            }
        }
        
        // 계산된 값들을 할당
        self.analystRatingsStrongBuy = strongBuy
        self.analystRatingsBuy = buy
        self.analystRatingsHold = hold
        self.analystRatingsSell = sell
        self.analystRatingsStrongSell = strongSell
        
        // Grade API에는 목표가 정보가 없음
        self.analystTargetPrice = nil
        self.analystTargetPriceHigh = nil
        self.analystTargetPriceLow = nil
    }
    
    // MARK: - Computed Properties
    
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
    
    /// 애널리스트 데이터가 유효한지 확인
    var hasValidData: Bool {
        // 등급 분포 중 하나라도 있거나, 목표가가 있으면 유효한 데이터로 간주
        let hasRatings = (analystRatingsStrongBuy ?? 0) > 0 ||
                        (analystRatingsBuy ?? 0) > 0 ||
                        (analystRatingsHold ?? 0) > 0 ||
                        (analystRatingsSell ?? 0) > 0 ||
                        (analystRatingsStrongSell ?? 0) > 0
        
        let hasTargetPrice = analystTargetPrice != nil && (analystTargetPrice ?? 0) > 0
        
        return hasRatings || hasTargetPrice
    }
    
    /// 총 애널리스트 수
    var totalAnalysts: Int {
        return (analystRatingsStrongBuy ?? 0) +
               (analystRatingsBuy ?? 0) +
               (analystRatingsHold ?? 0) +
               (analystRatingsSell ?? 0) +
               (analystRatingsStrongSell ?? 0)
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
        case 0.1..<1.5: return .verySell
        default: return .none
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
