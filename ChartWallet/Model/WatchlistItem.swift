//
//  WatchlistItem.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import Foundation

/// 관심 종목 모델
struct WatchlistItem: Identifiable, Codable, Equatable {
    /// 고유 식별자
    var id = UUID()
    /// 주식 심볼
    let symbol: String
    /// 회사명
    let name: String
    /// 관심목록 추가 날짜
    let addedDate: Date
    /// 정렬 순서 (드래그 앤 드롭으로 변경 가능)
    var sortOrder: Int
    
    init(symbol: String, name: String, sortOrder: Int) {
        self.symbol = symbol
        self.name = name
        self.addedDate = Date()
        self.sortOrder = sortOrder
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.symbol == rhs.symbol && lhs.name == rhs.name
    }
}
