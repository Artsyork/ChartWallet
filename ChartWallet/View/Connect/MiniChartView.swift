//
//  MiniChartView.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUICore
import Charts

struct MiniChartView: View {
    let data: [StockTrade]
    
    var body: some View {
        if data.count > 1 {
            let minPrice = data.map { $0.price }.min() ?? 0
            let maxPrice = data.map { $0.price }.max() ?? 100
            let priceRange = maxPrice - minPrice
            let isUptrend = data.last?.price ?? 0 > data.first?.price ?? 0
            
            Chart(data) { trade in
                LineMark(
                    x: .value("Time", trade.timestamp),
                    y: .value("Price", trade.price)
                )
                .foregroundStyle(isUptrend ? .green : .red)
                .lineStyle(StrokeStyle(lineWidth: 1.5))
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartBackground { _ in
                Rectangle()
                    .fill(Color.clear)
            }
            .background(
                LinearGradient(
                    colors: [
                        (isUptrend ? Color.green : Color.red).opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .overlay(
                    Text("📊")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                )
        }
    }
}
