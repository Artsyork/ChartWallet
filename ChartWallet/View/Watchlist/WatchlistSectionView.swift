//
//  WatchlistSectionView.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

struct WatchlistSectionView: View {
    let watchlist: [WatchlistItem]
    let stocks: [StockItem]
    @ObservedObject var portfolioManager: PortfolioManager
    let onStockSelected: (StockItem) -> Void
    
    @State private var isEditMode = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("정렬 변경")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(isEditMode ? "완료" : "편집") {
                    withAnimation {
                        isEditMode.toggle()
                    }
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(watchlist.sorted { $0.sortOrder < $1.sortOrder }) { item in
                    if let stock = stocks.first(where: { $0.symbol == item.symbol }) {
                        HStack {
                            if isEditMode {
                                Image(systemName: "line.horizontal.3")
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 8)
                            }
                            
                            StockCardView(stock: stock)
                                .onTapGesture {
                                    if !isEditMode {
                                        onStockSelected(stock)
                                    }
                                }
                        }
                    }
                }
                .onMove { source, destination in
                    if isEditMode {
                        portfolioManager.moveWatchlistItem(from: source, to: destination)
                    }
                }
                .onDelete { indexSet in
                    if isEditMode {
                        portfolioManager.removeFromWatchlist(at: indexSet)
                    }
                }
            }
        }
        .environment(\.editMode, isEditMode ? .constant(.active) : .constant(.inactive))
    }
}

#Preview {
    WatchlistSectionView(
        watchlist: [],
        stocks: [],
        portfolioManager: PortfolioManager(),
        onStockSelected: { _ in }
    )
}
