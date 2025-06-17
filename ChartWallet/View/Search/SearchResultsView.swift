//
//  SearchResultsView.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

// MARK: - Search Results View
struct SearchResultsView: View {
    @ObservedObject var searchManager: StockSearchManager
    @ObservedObject var portfolioManager: PortfolioManager
    @ObservedObject var stockManager: StockDataManager
    let onStockAdded: (String, String) -> Void
    let onShowStock: (StockItem) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if searchManager.isSearching {
                // 로딩 상태
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    
                    Text("검색 중...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if let error = searchManager.searchError {
                // 에러 상태
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    
                    Text("검색 오류")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(error)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("다시 시도") {
                        // 마지막 검색어로 다시 검색
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                
            } else if searchManager.searchResults.isEmpty {
                // 검색 결과 없음
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("검색 결과가 없습니다")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("다른 검색어를 시도해보세요")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else {
                // 검색 결과 리스트
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("검색 결과")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("\(searchManager.searchResults.count)개")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(searchManager.searchResults) { result in
                                SearchResultRow(
                                    result: result,
                                    portfolioManager: portfolioManager,
                                    stockManager: stockManager,
                                    onStockAdded: onStockAdded,
                                    onShowStock: onShowStock
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 100) // 탭바 여백
                    }
                }
            }
        }
    }
}
