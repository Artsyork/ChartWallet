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
            Chart(data) { trade in
                LineMark(
                    x: .value("Time", trade.timestamp),
                    y: .value("Price", trade.price)
                )
                .foregroundStyle(.cyan)
                .lineStyle(StrokeStyle(lineWidth: 1.5))
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartBackground { _ in
                Rectangle()
                    .fill(Color.clear)
            }
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    Text("📊")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                )
        }
    }
}
