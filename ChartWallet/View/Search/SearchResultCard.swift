//
//  SearchResultCard.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

// MARK: - Search Result Card (개선된 디자인)
struct SearchResultCard: View {
    let result: StockSearchManager.StockSearchResult
    @ObservedObject var portfolioManager: PortfolioManager
    @ObservedObject var stockManager: StockDataManager
    let onStockAdded: (String, String) -> Void
    
    @State private var isInWatchlist = false
    @State private var isInPortfolio = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // 종목 정보
                VStack(alignment: .leading, spacing: 6) {
                    // 심볼과 거래소
                    HStack {
                        Text(result.symbol)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        if let exchange = result.exchangeShortName {
                            Text(exchange)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                    
                    // 회사명
                    Text(result.name)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // 액션 버튼들
                VStack(spacing: 8) {
                    // 현재 가격 (이미 추적 중인 경우)
                    if let stock = stockManager.stocks.first(where: { $0.symbol == result.symbol }) {
                        if stock.currentPrice > 0 {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("$\(stock.currentPrice, specifier: "%.2f")")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                if stock.priceChange != 0 {
                                    HStack(spacing: 2) {
                                        Image(systemName: stock.priceChange >= 0 ? "arrow.up" : "arrow.down")
                                            .font(.caption2)
                                        
                                        Text("\(abs(stock.priceChangePercent), specifier: "%.1f")%")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(stock.priceChange >= 0 ? .green : .red)
                                }
                            }
                        }
                    }
                    
                    // 관심목록 버튼
                    if isInWatchlist {
                        Button("관심목록에서 제거") {
                            removeFromWatchlist()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    } else {
                        Button("관심목록에 추가") {
                            addToWatchlist()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
            }
            
            // 상태 표시
            if isInPortfolio || isInWatchlist {
                HStack {
                    if isInPortfolio {
                        Label("보유 중", systemImage: "briefcase.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(6)
                    }
                    
                    if isInWatchlist {
                        Label("관심목록", systemImage: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(6)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .onAppear {
            checkStatus()
        }
        .onChange(of: portfolioManager.watchlist) { _ in
            checkStatus()
        }
        .onChange(of: portfolioManager.portfolios) { _ in
            checkStatus()
        }
    }
    
    private func checkStatus() {
        isInWatchlist = portfolioManager.watchlist.contains { $0.symbol == result.symbol }
        isInPortfolio = portfolioManager.portfolios.contains { $0.symbol == result.symbol }
    }
    
    private func addToWatchlist() {
        portfolioManager.addToWatchlist(symbol: result.symbol, name: result.name)
        onStockAdded(result.symbol, result.name)
        checkStatus()
    }
    
    private func removeFromWatchlist() {
        if let index = portfolioManager.watchlist.firstIndex(where: { $0.symbol == result.symbol }) {
            portfolioManager.removeFromWatchlist(at: IndexSet(integer: index))
            checkStatus()
        }
    }
}
