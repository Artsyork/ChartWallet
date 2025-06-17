//
//  PopularStocksGuideView.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

// MARK: - Popular Stocks Guide View
struct PopularStocksGuideView: View {
    @ObservedObject var portfolioManager: PortfolioManager
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Image(systemName: "magnifyingglass.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("주식 검색")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("종목명이나 심볼을 입력하여\n원하는 주식을 검색해보세요")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("인기 종목 빠른 추가")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(portfolioManager.popularStocks.prefix(6), id: \.0) { symbol, name in
                        PopularStockQuickAddButton(
                            symbol: symbol,
                            name: name,
                            portfolioManager: portfolioManager
                        )
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}
