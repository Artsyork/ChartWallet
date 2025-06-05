//
//  StockDetailView.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUICore
import SwiftUI

struct StockDetailView: View {
    let stock: StockItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 헤더 정보
                    StockDetailHeaderView(stock: stock)
                    
                    // 상세 차트
                    if !stock.chartData.isEmpty {
                        DetailedChartView(data: stock.chartData, symbol: stock.symbol)
                    }
                    
                    // 애널리스트 평가
                    if let analystData = stock.analystData {
                        AnalystRecommendationView(recommendation: analystData, currentPrice: stock.currentPrice)
                    }
                }
                .padding()
            }
            .navigationTitle(stock.symbol)
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("닫기") { dismiss() })
            .preferredColorScheme(.dark)
            .background(Color.black.ignoresSafeArea())
        }
        .preferredColorScheme(.dark)
    }
}
