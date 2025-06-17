//
//  SearchGuideView.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

// MARK: - Search Guide View
struct SearchGuideView: View {
    @ObservedObject var portfolioManager: PortfolioManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 가이드 헤더
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 8) {
                        Text("주식 검색")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("종목명이나 심볼을 입력하여\n원하는 주식을 검색해보세요")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 40)
                
                // 검색 예시
                VStack(alignment: .leading, spacing: 12) {
                    Text("검색 예시")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        SearchExampleRow(symbol: "AAPL", description: "Apple Inc.")
                        SearchExampleRow(symbol: "TSLA", description: "Tesla Inc.")
                        SearchExampleRow(symbol: "Apple", description: "회사명으로도 검색 가능")
                    }
                }
                .padding(.horizontal, 20)
                
                // 인기 종목 빠른 추가
                VStack(alignment: .leading, spacing: 16) {
                    Text("인기 종목 빠른 추가")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                    
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
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 100)
            }
        }
    }
}
