//
//  DetailedChartView.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUICore
import Charts

struct DetailedChartView: View {
    let data: [StockTrade]
    let symbol: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("실시간 차트")
                .font(.headline)
                .fontWeight(.semibold)
            
            Chart(data) { trade in
                LineMark(
                    x: .value("시간", trade.timestamp),
                    y: .value("가격", trade.price)
                )
                .foregroundStyle(.cyan)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)
                
                if trade.id == data.last?.id {
                    PointMark(
                        x: .value("시간", trade.timestamp),
                        y: .value("가격", trade.price)
                    )
                    .foregroundStyle(.cyan)
                    .symbolSize(50)
                }
            }
            .frame(height: 300)
            .chartXAxis {
                AxisMarks(values: .stride(by: .minute, count: 5)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour().minute())
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .currency(code: "USD"))
                }
            }
            .chartBackground { _ in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.cyan.opacity(0.1), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}
