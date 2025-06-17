//
//  PopularStockQuickAddButton.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

struct PopularStockQuickAddButton: View {
    let symbol: String
    let name: String
    @ObservedObject var portfolioManager: PortfolioManager
    
    @State private var isInWatchlist = false
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 4) {
                Text(symbol)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            if isInWatchlist {
                Button("추가됨") {
                    // 이미 추가된 상태
                }
                .disabled(true)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.3))
                .foregroundColor(.green)
                .cornerRadius(6)
            } else {
                Button("추가") {
                    portfolioManager.addToWatchlist(symbol: symbol, name: name)
                    checkStatus()
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(6)
            }
        }
        .padding()
        .frame(height: 100)
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
    }
    
    private func checkStatus() {
        isInWatchlist = portfolioManager.watchlist.contains { $0.symbol == symbol }
    }
}
