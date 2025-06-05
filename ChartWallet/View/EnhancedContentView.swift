//
//  EnhancedContentView.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUICore
import SwiftUI

// MARK: - Enhanced Views
struct EnhancedContentView: View {
    @StateObject private var webSocketManager = EnhancedFinnhubWebSocketManager()
    @State private var selectedSymbol = "AAPL"
    @State private var customSymbol = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let popularSymbols = ["AAPL", "GOOGL", "MSFT", "TSLA", "AMZN", "NVDA"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 연결 및 네트워크 상태
                EnhancedStatusView(
                    connectionStatus: webSocketManager.connectionStatus,
                    isNetworkConnected: webSocketManager.networkMonitor.isConnected,
                    connectionType: webSocketManager.networkMonitor.connectionType
                )
                
                // 주식 선택
                StockSelectorView(
                    selectedSymbol: $selectedSymbol,
                    customSymbol: $customSymbol,
                    popularSymbols: popularSymbols,
                    onSymbolSelected: { symbol in
                        webSocketManager.unsubscribe(from: selectedSymbol)
                        selectedSymbol = symbol
                        webSocketManager.subscribe(to: symbol)
                    }
                )
                
                // 현재 가격 정보
                CurrentPriceView(
                    symbol: selectedSymbol,
                    price: webSocketManager.currentPrice,
                    change: webSocketManager.priceChange
                )
                
                // 실시간 차트
                if !webSocketManager.chartData.isEmpty {
                    RealTimeChartView(data: webSocketManager.chartData)
                        .frame(height: 300)
                        .padding()
                }
                
                // 최근 거래 내역
                TradeListView(trades: webSocketManager.trades)
                
                Spacer()
            }
            .navigationTitle("실시간 주식 차트")
            .alert("알림", isPresented: $showingAlert) {
                Button("확인") { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                if webSocketManager.networkMonitor.isConnected {
                    webSocketManager.connect()
                } else {
                    showNetworkAlert()
                }
            }
            .onDisappear {
                webSocketManager.disconnect()
            }
            .onChange(of: webSocketManager.networkMonitor.isConnected) { isConnected in
                if !isConnected {
                    showNetworkAlert()
                }
            }
        }
    }
    
    private func showNetworkAlert() {
        alertMessage = "네트워크 연결을 확인해주세요"
        showingAlert = true
    }
}
