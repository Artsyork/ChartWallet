//
//  SearchResultRow.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

// MARK: - Search Result Row
struct SearchResultRow: View {
    let result: StockSearchManager.StockSearchResult
    @ObservedObject var portfolioManager: PortfolioManager
    @ObservedObject var stockManager: StockDataManager
    let onStockAdded: (String, String) -> Void
    let onShowStock: (StockItem) -> Void
    
    @State private var isInWatchlist = false
    @State private var isInPortfolio = false
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(result.symbol)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(result.name)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let exchange = result.exchangeShortName {
                    Text(exchange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                        )
                }
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                // 현재 가격 (만약 이미 추적 중이라면)
                if let stock = stockManager.stocks.first(where: { $0.symbol == result.symbol }) {
                    VStack(alignment: .trailing, spacing: 2) {
                        if stock.currentPrice > 0 {
                            Text("$\(stock.currentPrice, specifier: "%.2f")")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
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
                    
                    Button("상세보기") {
                        onShowStock(stock)
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    
                } else {
                    // 관심목록에 추가/제거 버튼
                    if isInWatchlist {
                        Button("관심목록 제거") {
                            removeFromWatchlist()
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    } else {
                        Button("관심목록 추가") {
                            addToWatchlist()
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                }
                
                // 포트폴리오 상태 표시
                if isInPortfolio {
                    Text("보유 중")
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue.opacity(0.2))
                        )
                }
            }
        }
        .padding()
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
