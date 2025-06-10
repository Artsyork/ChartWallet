//
//  PopularStockCard.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUICore

struct PopularStockCard: View {
    let stock: StockItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(stock.symbol)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(stock.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if !stock.chartData.isEmpty {
                    MiniChartView(data: stock.chartData)
                        .frame(width: 40, height: 20)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if stock.currentPrice > 0 {
                    Text("$\(stock.currentPrice, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                } else {
                    Text("--")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                if stock.priceChange != 0 {
                    HStack(spacing: 4) {
                        Image(systemName: stock.priceChange >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption2)
                        
                        Text("\(abs(stock.priceChangePercent), specifier: "%.1f")%")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(stock.priceChange >= 0 ? .green : .red)
                } else {
                    Text("0.0%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(width: 140, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    stock.priceChange > 0 ? Color.green.opacity(0.3) :
                    stock.priceChange < 0 ? Color.red.opacity(0.3) :
                    Color.clear,
                    lineWidth: 1
                )
        )
    }
}
