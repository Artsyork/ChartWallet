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
    
    /// 1. 순번
    let seq: Int
    /// 2. 회사명
    let companyName: String
    /// 3. 현재가 (원화)
    let currentPrice: Double?
    /// 4. 섹터
    let sector: String?
    /// 5. 산업
    let industry: String?
    /// 6. 애널리스트 평가
    let analystRating: String?
    /// 7. 애널리스트 목표가
    let analystTargetPrice: Double?
    /// 8. 예상 수익률
    let expectedReturn: Double?
    /// 9. 52주 최고가
    let week52High: Double?
    /// 10. 52주 최저가
    let week52Low: Double?
    /// 11. 사상 최고가 (All-Time High)
    let allTimeHigh: Double?
    /// 국가 (가격 화폐 단위 결정)
    let country: Country
    /// 업로드 일시
    let uploadDate: Date
    
    init(seq: Int, companyName: String, currentPrice: Double?, sector: String?,
         industry: String?, analystRating: String?, analystTargetPrice: Double?,
         expectedReturn: Double?, week52High: Double?, week52Low: Double?,
         allTimeHigh: Double?, country: Country = .KR) {
        self.seq = seq
        self.companyName = companyName
        self.currentPrice = currentPrice
        self.sector = sector
        self.industry = industry
        self.analystRating = analystRating
        self.analystTargetPrice = analystTargetPrice
        self.expectedReturn = expectedReturn
        self.week52High = week52High
        self.week52Low = week52Low
        self.allTimeHigh = allTimeHigh
        self.country = country
        self.uploadDate = Date()
    }
    
    // MARK: - 화폐 표시 헬퍼 메서드
    
    /// 포맷된 현재가 문자열
    var formattedCurrentPrice: String {
        guard let price = currentPrice else { return "--" }
        var format: String
        
        switch country {
        case .KR:
            format = String(format: "%.0f", price)
            return format.getFormattedMoney() + "원"
        case .USA:
            format = String(format: "%.2f", price)
            return "$" + format.getFormattedMoney()
        }
    }
    
    /// 포맷된 목표가 문자열 (애널리스트 평가 필드 값 사용)
    var formattedTargetPrice: String {
        guard let targetPrice = analystTargetPrice else { return "--" }
        var format: String
        
        switch country {
        case .KR:
            format = String(format: "%.0f", targetPrice)
            return format.getFormattedMoney() + "원"
        case .USA:
            format = String(format: "%.2f", targetPrice)
            return "$" + format.getFormattedMoney()
        }
    }
    
    /// 포맷된 52주 최고가
    var formattedWeek52High: String {
        guard let price = week52High else { return "--" }
        var format: String
        
        switch country {
        case .KR:
            format = String(format: "%.0f", price)
            return format.getFormattedMoney() + "원"
        case .USA:
            format = String(format: "%.2f", price)
            return "$" + format.getFormattedMoney()
        }
    }
    
    /// 포맷된 52주 최저가
    var formattedWeek52Low: String {
        guard let price = week52Low else { return "--" }
        var format: String
        
        switch country {
        case .KR:
            format = String(format: "%.0f", price)
            return format.getFormattedMoney() + "원"
        case .USA:
            format = String(format: "%.2f", price)
            return "$" + format.getFormattedMoney()
        }
    }
    
    /// 포맷된 ATH
    var formattedAllTimeHigh: String {
        guard let price = allTimeHigh else { return "--" }
        var format: String
        
        switch country {
        case .KR:
            format = String(format: "%.0f", price)
            return format.getFormattedMoney() + "원"
        case .USA:
            format = String(format: "%.2f", price)
            return "$" + format.getFormattedMoney()
        }
    }
    
    var formatBuyComment: BuyComment {
        return .create(string: analystRating ?? "")
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.companyName == rhs.companyName && lhs.sector == rhs.sector && lhs.industry == rhs.industry
    }
}
