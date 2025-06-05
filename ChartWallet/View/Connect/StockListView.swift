//
//  StockListView.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUICore
import SwiftUI

struct StockListView: View {
    let stocks: [StockItem]
    let onStockSelected: (StockItem) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(stocks) { stock in
                    StockCardView(stock: stock)
                        .onTapGesture {
                            onStockSelected(stock)
                        }
                }
            }
            .padding()
        }
    }
}
