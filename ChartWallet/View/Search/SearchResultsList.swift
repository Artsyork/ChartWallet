//
//  SearchResultsList.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

struct SearchResultsList: View {
    let results: [StockSearchManager.StockSearchResult]
    @ObservedObject var portfolioManager: PortfolioManager
    @ObservedObject var stockManager: StockDataManager
    let onStockAdded: (String, String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 결과 헤더
            HStack {
                Text("검색 결과")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(results.count)개")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // 결과 리스트
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(results) { result in
                        SearchResultCard(
                            result: result,
                            portfolioManager: portfolioManager,
                            stockManager: stockManager,
                            onStockAdded: onStockAdded
                        )
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 100)
            }
        }
    }
}
