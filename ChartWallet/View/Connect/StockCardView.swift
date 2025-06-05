//
//  StockCardView.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUICore

struct StockCardView: View {
    let stock: StockItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 종목 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(stock.symbol)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(stock.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 미니 차트
            if !stock.chartData.isEmpty {
                MiniChartView(data: stock.chartData)
                    .frame(width: 60, height: 30)
            }
            
            Spacer()
            
            // 가격 정보
            VStack(alignment: .trailing, spacing: 4) {
                if stock.currentPrice > 0 {
                    Text("$\(stock.currentPrice, specifier: "%.2f")")
                        .font(.headline)
                        .fontWeight(.semibold)
                } else {
                    Text("--")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                if stock.priceChange != 0 {
                    HStack(spacing: 4) {
                        Image(systemName: stock.priceChange >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption2)
                        
                        Text("\(abs(stock.priceChangePercent), specifier: "%.2f")%")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(stock.priceChange >= 0 ? .green : .red)
                } else {
                    Text("0.00%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(stock.priceChange >= 0 ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}
