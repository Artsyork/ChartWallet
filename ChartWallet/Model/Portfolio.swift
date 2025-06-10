//
//  Portfolio.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import Foundation

/// 포트폴리오 모델
struct Portfolio: Identifiable, Codable {
    /// 고유 식별자
    var id = UUID()
    /// 주식 심볼
    let symbol: String
    /// 회사명
    let name: String
    /// 보유 수량 (소수점 지원)
    var quantity: Double
    /// 평균 매수가
    var averagePrice: Double
    /// 매수 날짜
    let purchaseDate: Date
    
    /// 총 투자 금액
    var totalInvestment: Double {
        quantity * averagePrice
    }
    
    /// 현재 평가 금액 (현재 주가 필요)
    func currentValue(currentPrice: Double) -> Double {
        quantity * currentPrice
    }
    
    /// 수익/손실 금액
    func profitLoss(currentPrice: Double) -> Double {
        currentValue(currentPrice: currentPrice) - totalInvestment
    }
    
    /// 수익률 (%)
    func profitLossPercent(currentPrice: Double) -> Double {
        guard totalInvestment > 0 else { return 0 }
        return (profitLoss(currentPrice: currentPrice) / totalInvestment) * 100
    }
}
