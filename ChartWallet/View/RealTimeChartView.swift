//
//  RealTimeChartView.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUI
import Charts
import SwiftUICore

struct RealTimeChartView: View {
    let data: [StockTrade]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("실시간 가격 차트")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(data.count) 데이터 포인트")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Chart(data) { trade in
                LineMark(
                    x: .value("시간", trade.timestamp),
                    y: .value("가격", trade.price)
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)
                
                // 현재 가격 포인트 강조
                if trade.id == data.last?.id {
                    PointMark(
                        x: .value("시간", trade.timestamp),
                        y: .value("가격", trade.price)
                    )
                    .foregroundStyle(.blue)
                    .symbolSize(50)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .minute, count: 2)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour().minute())
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .currency(code: "USD"))
                }
            }
            .chartBackground { chartProxy in
                // 차트 배경 그라디언트
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.1), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .animation(.easeInOut(duration: 0.5), value: data.count)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}
