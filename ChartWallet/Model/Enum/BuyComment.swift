//
//  BuyComment.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUICore

enum BuyComment: String {
    case veryGood
    case good
    case stay
    case sell
    case verySell
    case none
    
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
    
    static func create(string: String) -> Self {
        switch string {
        case "스트롱 바이": return .veryGood
        case "바이": return .good
        case "뉴트럴": return .stay
        case "셀": return .sell
        case "스트롱 셀": return .verySell
        default: return .none
        }
    }
    
    var rawKr: String {
        switch self {
        case .veryGood: return "스트롱 바이"
        case .good: return "바이"
        case .stay: return "뉴트럴"
        case .sell: return "셀"
        case .verySell: return "스트롱 셀"
        case .none: return "--"
        }
    }
    
    var kr: String {
        switch self {
        case .veryGood: return "적극 구매"
        case .good: return "구매"
        case .stay: return "유지"
        case .sell: return "판매"
        case .verySell: return "적극 판매"
        case .none: return "N/A"
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
