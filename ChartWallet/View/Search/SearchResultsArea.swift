//
//  SearchResultsArea.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

// MARK: - Search Results Area
struct SearchResultsArea: View {
    @ObservedObject var searchManager: StockSearchManager
    @ObservedObject var portfolioManager: PortfolioManager
    @ObservedObject var stockManager: StockDataManager
    let onStockAdded: (String, String) -> Void
    
    var body: some View {
        Group {
            if let error = searchManager.searchError {
                // 에러 상태
                SearchErrorView(error: error) {
                    // 재시도 로직 필요시 구현
                }
            } else if searchManager.searchResults.isEmpty && !searchManager.isSearching {
                // 검색 결과 없음
                NoResultsView()
            } else {
                // 검색 결과 리스트
                SearchResultsList(
                    results: searchManager.searchResults,
                    portfolioManager: portfolioManager,
                    stockManager: stockManager,
                    onStockAdded: onStockAdded
                )
            }
        }
    }
}
