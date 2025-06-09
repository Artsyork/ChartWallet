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
        VStack(spacing: 0) {
            
            //StockListHeaderView()
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(stocks) { stock in
                        StockCardView(stock: stock)
                            .onTapGesture {
                                onStockSelected(stock)
                            }
                    }
                }
            }
        }
        .padding()
    }
}
#Preview {
    StockListView(stocks: [.init(symbol: "Test", name: "Test")], onStockSelected: { _ in })
}
