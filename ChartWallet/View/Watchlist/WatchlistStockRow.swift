//
//  WatchlistStockRow.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUICore
import SwiftUI

struct WatchlistStockRow: View {
    let stock: StockItem
    let onTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 종목 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(stock.symbol)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(stock.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(width: 80, alignment: .leading)
            
            // 미니 차트
            if !stock.chartData.isEmpty {
                MiniChartView(data: stock.chartData)
                    .frame(width: 60, height: 30)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 30)
                    .overlay(
                        Text("📊")
                            .font(.caption2)
                    )
            }
            
            // 애널리스트 평가
            VStack(spacing: 2) {
                if let analystData = stock.analystData {
                    Text(analystData.averageRating.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(analystData.averageRating.color)
                        .multilineTextAlignment(.center)
                } else {
                    Text("--")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 50)
            
            // 목표가
            VStack(spacing: 2) {
                if let analystData = stock.analystData,
                   let targetPrice = analystData.analystTargetPrice {
                    Text("$\(targetPrice, specifier: "%.0f")")
                        .font(.caption)
                        .fontWeight(.medium)
                } else {
                    Text("--")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 45)
            
            // 수익률
            VStack(spacing: 2) {
                if let analystData = stock.analystData,
                   let targetPrice = analystData.analystTargetPrice,
                   stock.currentPrice > 0 {
                    let upside = ((targetPrice - stock.currentPrice) / stock.currentPrice) * 100
                    Text("\(upside, specifier: "%.1f")%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(upside >= 0 ? .green : .red)
                } else {
                    Text("--")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 45)
            
            Spacer()
            
            // 현재가
            VStack(alignment: .trailing, spacing: 2) {
                if stock.currentPrice > 0 {
                    Text("$\(stock.currentPrice, specifier: "%.2f")")
                        .font(.headline)
                        .fontWeight(.bold)
                } else {
                    Text("--")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                if stock.priceChange != 0 {
                    HStack(spacing: 2) {
                        Image(systemName: stock.priceChange >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption2)
                        
                        Text("\(abs(stock.priceChangePercent), specifier: "%.1f")%")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(stock.priceChange >= 0 ? .green : .red)
                } else {
                    Text("0.0%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // 삭제 버튼
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            }
        }
        .padding()
        .background(Color.clear)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
    
    private func ratingColor(for rating: String) -> Color {
        switch rating {
        case "Strong Buy": return .green
        case "Buy": return .mint
        case "Hold": return .yellow
        case "Sell": return .orange
        case "Strong Sell": return .red
        default: return .secondary
        }
    }
}
