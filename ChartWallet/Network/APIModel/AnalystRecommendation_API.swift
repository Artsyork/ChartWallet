//
//  AnalystRecommendation_API.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

/// 애널리스트 추천 정보 조회 API (개별 종목)
struct AnalystRecommendation_API: Codable {
    
    static let endPoint = "https://financialmodelingprep.com/api/v3/grade"
    
    struct Request: Codable {
        /// 주식 심볼
        let symbol: String
        /// API 키
        let apikey: String
    }
    
    struct Response: Codable {
        /// 주식 심볼
        let symbol: String
        /// 발행일
        let date: String?
        /// 등급 부여 회사
        let gradingCompany: String?
        /// 이전 등급
        let previousGrade: String?
        /// 새로운 등급
        let newGrade: String?
        /// 뉴스 URL
        let newsURL: String?
    }
    
    struct Path: Codable {
        /// 주식 심볼 (URL 경로에 포함)
        let symbol: String
    }
    
}
