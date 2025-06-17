//
//  HomeView.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var stockManager: StockDataManager
    @ObservedObject var portfolioManager: PortfolioManager
    @State private var selectedStock: StockItem?
    @State private var showingAddToWatchlist = false
    @State private var showingStockSearch = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 검색 바 (탭하면 검색 화면으로 이동)
                    SearchBarPlaceholder {
                        showingStockSearch = true
                    }
                    .padding(.horizontal)
                    
                    // 연결 상태 헤더
                    ConnectionHeaderView(
                        status: stockManager.connectionStatus,
                        lastAnalystUpdate: stockManager.lastAnalystUpdate,
                        nextAnalystUpdate: stockManager.nextAnalystUpdate,
                        onConnect: { stockManager.connect() },
                        onForceUpdate: { stockManager.forceUpdateAnalystData() }
                    )
                    
                    // 인기 종목 섹션
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("인기 종목")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        let popularStocks = stockManager.stocks.filter { stock in
                            portfolioManager.popularStocks.contains { $0.0 == stock.symbol }
                        }.prefix(7)
                        
                        ForEach(Array(popularStocks)) { stock in
                            StockCardView(stock: stock)
                                .padding(.horizontal)
                                .onTapGesture {
                                    selectedStock = stock
                                }
                        }
                    }
                    
                    // 관심 종목 섹션
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("관심 종목")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button("편집") {
                                showingAddToWatchlist = true
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                        }
                        .padding(.horizontal)
                        
                        // 관심목록 (정렬 가능)
                        WatchlistSectionView(
                            watchlist: portfolioManager.watchlist,
                            stocks: stockManager.stocks,
                            portfolioManager: portfolioManager,
                            onStockSelected: { stock in
                                selectedStock = stock
                            }
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 100) // 탭바 여백
            }
            .navigationTitle("홈")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedStock) { stock in
            StockDetailView(stock: stock)
        }
        .sheet(isPresented: $showingAddToWatchlist) {
            WatchlistEditView(portfolioManager: portfolioManager)
        }
        .sheet(isPresented: $showingStockSearch) {
            StockSearchView(
                portfolioManager: portfolioManager,
                stockManager: stockManager
            )
        }
    }
}

#Preview {
    HomeView(
        stockManager: StockDataManager(),
        portfolioManager: PortfolioManager()
    )
}
