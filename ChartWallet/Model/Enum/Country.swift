//
//  Country.swift
//  ChartWallet
//
//  Created by DY on 6/23/25.
//

import Foundation

// MARK: - Country Enum
enum Country: String, Codable, CaseIterable {
    case KR = "KR"
    case USA = "USA"
    
    var currencySymbol: String {
        switch self {
        case .KR:
            return "원"
        case .USA:
            return "$"
        }
    }
    
    var currencyName: String {
        switch self {
        case .KR:
            return "원"
        case .USA:
            return "달러"
        }
    }
    
    var displayName: String {
        switch self {
        case .KR:
            return "한국"
        case .USA:
            return "미국"
        }
    }
}
