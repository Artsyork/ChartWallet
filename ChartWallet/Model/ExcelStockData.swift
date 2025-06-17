//
//  ExcelStockData.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import Foundation

// MARK: - Excel Stock Data Model
struct ExcelStockData: Identifiable, Codable, Equatable {
    var id = UUID()
    
    /// 순번
    let seq: Int
    /// 회사명
    let companyName: String
    /// 현재가 (원화)
    let currentPriceKRW: Double?
    /// 현재가 (달러)
    let currentPriceUSD: Double?
    /// 섹터
    let sector: String?
    /// 산업
    let industry: String?
    /// 애널리스트 평가
    let analystRating: String?
    /// 애널리스트 목표가
    let analystTargetPrice: Double?
    /// 예상 수익률
    let expectedReturn: Double?
    /// 52주 최고가
    let week52High: Double?
    /// 52주 최저가
    let week52Low: Double?
    /// 사상 최고가 (All-Time High)
    let allTimeHigh: Double?
    
    /// 업로드 일시
    let uploadDate: Date
    
    init(seq: Int, companyName: String, currentPriceKRW: Double?, currentPriceUSD: Double?,
         sector: String?, industry: String?, analystRating: String?, analystTargetPrice: Double?,
         expectedReturn: Double?, week52High: Double?, week52Low: Double?, allTimeHigh: Double?) {
        self.seq = seq
        self.companyName = companyName
        self.currentPriceKRW = currentPriceKRW
        self.currentPriceUSD = currentPriceUSD
        self.sector = sector
        self.industry = industry
        self.analystRating = analystRating
        self.analystTargetPrice = analystTargetPrice
        self.expectedReturn = expectedReturn
        self.week52High = week52High
        self.week52Low = week52Low
        self.allTimeHigh = allTimeHigh
        self.uploadDate = Date()
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.companyName == rhs.companyName && lhs.sector == rhs.sector && lhs.industry == rhs.industry
    }
}
