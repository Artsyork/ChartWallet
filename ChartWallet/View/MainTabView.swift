//
//  MainTabView.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var stockManager = StockDataManager()
    @StateObject private var portfolioManager = PortfolioManager()
    
    var body: some View {
        TabView {
            HomeView(stockManager: stockManager, portfolioManager: portfolioManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("홈")
                }
            
            PortfolioView(stockManager: stockManager, portfolioManager: portfolioManager)
                .tabItem {
                    Image(systemName: "briefcase.fill")
                    Text("내 자산")
                }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // 포트폴리오와 관심목록의 모든 종목에 대해 데이터 로드
            stockManager.updateStockSymbols(portfolioManager.getAllUniqueSymbols())
            stockManager.connect()
        }
    }
}

#Preview {
    MainTabView()
}
