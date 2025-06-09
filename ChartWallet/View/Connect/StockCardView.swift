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
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                // 1. 종목명
                VStack(alignment: .leading, spacing: 2) {
                    Text(stock.symbol)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(stock.name)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)  // 최소 30%까지 축소
                        .truncationMode(.tail)    // 잘릴 때 끝에 ... 표시
                }
                .frame(width: 80, alignment: .leading)
                
//                // 2. 그래프
//                VStack {
//                    if !stock.chartData.isEmpty {
//                        MiniChartView(data: stock.chartData)
//                            .frame(width: 50, height: 25)
//                    } else {
//                        Rectangle()
//                            .fill(Color.gray.opacity(0.2))
//                            .frame(width: 50, height: 25)
//                            .overlay(
//                                Text("📊")
//                                    .font(.caption2)
//                                    .foregroundColor(.secondary)
//                            )
//                    }
//                    
//                    Text("차트")
//                        .font(.caption2)
//                        .foregroundColor(.secondary)
//                }
//                .frame(width: 50)
                
                // 3. 애널리스트 평가
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
                    
                    Text("평가")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(width: 40)
                
                // 4. 애널리스트 목표가
                VStack(spacing: 2) {
                    if let analystData = stock.analystData,
                       let targetPrice = analystData.analystTargetPrice {
                        Text("$\(targetPrice, specifier: "%.0f")")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    } else {
                        Text("--")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("목표가")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(width: 40)
                
                // 5. 예상 수익률
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
                    
                    Text("수익률")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(width: 40)
                
                Spacer()
                
                // 6. 현재주가
                VStack(alignment: .trailing, spacing: 2) {
                    if stock.currentPrice > 0 {
                        Text("$\(stock.currentPrice, specifier: "%.2f")")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .minimumScaleFactor(0.3)  // 최소 30%까지 축소
                            .lineLimit(1)
                    } else {
                        Text("--")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    // 가격 변동
                    if stock.priceChange != 0 {
                        HStack(spacing: 2) {
                            Image(systemName: stock.priceChange >= 0 ? "arrow.up" : "arrow.down")
                                .font(.caption2)
                            
                            Text("\(abs(stock.priceChangePercent), specifier: "%.1f")%")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .minimumScaleFactor(0.5)  // 최소 50%까지 축소
                                .lineLimit(1)
                        }
                        .foregroundColor(stock.priceChange >= 0 ? .green : .red)
                    } else {
                        Text("0.0%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 80, alignment: .trailing)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6).opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    stock.priceChange > 0 ? Color.green.opacity(0.3) :
                        stock.priceChange < 0 ? Color.red.opacity(0.3) :
                        Color.clear,
                    lineWidth: 1
                )
        )
    }
    
}
