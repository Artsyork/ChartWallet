//
//  MyHolding.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import Foundation

/// 보유 주식
struct MyHolding: Identifiable, Codable {
    var id = UUID()
    let symbol: String
    let name: String
    let quantity: Double
    let purchasePrice: Double
    let purchaseDate: Date
    
    var totalValue: Double {
        quantity * purchasePrice
    }
    
    init(symbol: String, name: String, quantity: Double, purchasePrice: Double) {
        self.symbol = symbol
        self.name = name
        self.quantity = quantity
        self.purchasePrice = purchasePrice
        self.purchaseDate = Date()
    }
}
