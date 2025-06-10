//
//  PortfolioCardView.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI
import Charts

struct PortfolioCardView: View {
    let portfolio: Portfolio
    let currentStock: StockItem?
    
    @State private var selectedTimeRange: TimeRange = .oneDay
    
    enum TimeRange: String, CaseIterable {
        case oneDay = "1D"
        case oneWeek = "1W"
        case oneMonth = "1M"
        case threeMonths = "3M"
        case sixMonths = "6M"
        case oneYear = "1Y"
    }
    
    private var currentPrice: Double {
        currentStock?.currentPrice ?? portfolio.averagePrice
    }
    
    private var profitLoss: Double {
        portfolio.profitLoss(currentPrice: currentPrice)
    }
    
    private var profitLossPercent: Double {
        portfolio.profitLossPercent(currentPrice: currentPrice)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // 헤더 - 종목 정보
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(portfolio.symbol)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    if let analystData = currentStock?.analystData {
                        Text(analystData.averageRating.rawValue)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(analystData.averageRating.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(analystData.averageRating.color.opacity(0.2))
                            )
                    }
                }
                
                Text(portfolio.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // 현재 가격 및 수익률
            VStack(spacing: 4) {
                Text("$\(currentPrice, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                
                HStack(spacing: 4) {
                    Image(systemName: profitLoss >= 0 ? "arrow.up" : "arrow.down")
                        .font(.caption2)
                    
                    Text("\(abs(profitLossPercent), specifier: "%.1f")%")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(profitLoss >= 0 ? .green : .red)
            }
            
            // 미니 차트 (시간대별)
            VStack(spacing: 8) {
                // 시간대 선택
                HStack(spacing: 4) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Button(range.rawValue) {
                            selectedTimeRange = range
                        }
                        .font(.caption2)
                        .foregroundColor(selectedTimeRange == range ? .white : .secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(selectedTimeRange == range ? Color.blue : Color.clear)
                        )
                    }
                }
                
                // 차트
                if let chartData = currentStock?.chartData, !chartData.isEmpty {
                    Chart(chartData.suffix(20)) { trade in
                        LineMark(
                            x: .value("시간", trade.timestamp),
                            y: .value("가격", trade.price)
                        )
                        .foregroundStyle(profitLoss >= 0 ? .green : .red)
                        .lineStyle(StrokeStyle(lineWidth: 1.5))
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .frame(height: 40)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 40)
                        .overlay(
                            Text("📊")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        )
                }
            }
            
            // 보유 정보
            VStack(spacing: 4) {
                HStack {
                    Text("보유수량")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(portfolio.quantity, specifier: "%.3f")주")
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("평균단가")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("$\(portfolio.averagePrice, specifier: "%.2f")")
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("평가손익")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("$\(profitLoss, specifier: "%.2f")")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(profitLoss >= 0 ? .green : .red)
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
                .stroke(
                    profitLoss > 0 ? Color.green.opacity(0.3) :
                        profitLoss < 0 ? Color.red.opacity(0.3) :
                        Color.clear,
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    PortfolioCardView(
        portfolio: Portfolio(
            symbol: "AAPL",
            name: "Apple Inc.",
            quantity: 10.5,
            averagePrice: 150.00,
            purchaseDate: Date()
        ),
        currentStock: nil
    )
    .frame(width: 180)
}
