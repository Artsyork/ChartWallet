//
//  PopularStocksSection.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUICore
import SwiftUI

// MARK: - Popular Stocks Section
struct PopularStocksSection: View {
    let stocks: [StockItem]
    let onStockSelected: (StockItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("인기 종목")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(stocks.count)/7")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(stocks) { stock in
                        PopularStockCard(stock: stock)
                            .onTapGesture {
                                onStockSelected(stock)
                            }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}
