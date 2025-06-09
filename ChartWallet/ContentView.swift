//
//  ContentView.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var stockManager = StockDataManager()
    @State private var selectedStock: StockItem?
    
    var body: some View {
        NavigationView {
            VStack {
                // 연결 상태 헤더
                ConnectionHeaderView(
                    status: stockManager.connectionStatus,
                    lastAnalystUpdate: stockManager.lastAnalystUpdate,
                    nextAnalystUpdate: stockManager.nextAnalystUpdate,
                    onConnect: { stockManager.connect() },
                    onForceUpdate: { stockManager.forceUpdateAnalystData() }
                )
                
                // 주식 목록
                StockListView(
                    stocks: stockManager.stocks,
                    onStockSelected: { stock in
                        selectedStock = stock
                    }
                )
            }
            .navigationTitle("주식 실시간")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .background(Color.black.ignoresSafeArea())
            .onAppear {
                stockManager.connect()
            }
            .sheet(item: $selectedStock) { stock in
                StockDetailView(stock: stock)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
