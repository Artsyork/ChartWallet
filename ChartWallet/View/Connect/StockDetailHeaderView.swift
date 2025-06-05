//
//  StockDetailHeaderView.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUICore

struct StockDetailHeaderView: View {
    let stock: StockItem
    
    var body: some View {
        VStack(spacing: 12) {
            Text(stock.name)
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Text("$\(stock.currentPrice, specifier: "%.2f")")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack {
                Image(systemName: stock.priceChange >= 0 ? "arrow.up" : "arrow.down")
                Text("$\(abs(stock.priceChange), specifier: "%.2f") (\(abs(stock.priceChangePercent), specifier: "%.2f")%)")
            }
            .foregroundColor(stock.priceChange >= 0 ? .green : .red)
            .font(.headline)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}
