//
//  WebSocketMessage.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

struct WebSocketMessage: Codable {
    let data: [StockTrade]?
    let type: String?
}
