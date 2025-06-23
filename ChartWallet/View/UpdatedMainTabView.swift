//
//  UpdatedMainTabView.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUI

struct UpdatedMainTabView: View {
    @StateObject private var stockManager = StockDataManager()
    @StateObject private var portfolioManager = PortfolioManager()
    @StateObject private var excelManager = ExcelImportManager()
    
    var body: some View {
        TabView {
            // 홈 탭 (API 데이터)
            UpdatedHomeView(
                stockManager: stockManager,
                portfolioManager: portfolioManager
            )
            .tabItem {
                Image(systemName: "house.fill")
                Text("홈")
            }
            
            // CSV 데이터 탭 (새로 추가)
            CSVDataView(
                excelManager: excelManager,
                portfolioManager: portfolioManager,
                stockManager: stockManager
            )
            .tabItem {
                Image(systemName: "doc.text.fill")
                Text("CSV 데이터")
            }
            .badge(excelManager.importedStocks.isEmpty ? 0 : excelManager.importedStocks.count)
            
            // 내 자산 탭
            UpdatedPortfolioView(
                stockManager: stockManager,
                portfolioManager: portfolioManager
            )
            .tabItem {
                Image(systemName: "briefcase.fill")
                Text("내 자산")
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // 포트폴리오와 관심목록의 모든 종목에 대해 데이터 로드
            let allSymbols = portfolioManager.getAllUniqueSymbols()
            
            // 엑셀에서 가져온 데이터도 추가
            let excelSymbols = excelManager.convertToStockItems().map { $0.symbol }
            let combinedSymbols = Array(Set(allSymbols + excelSymbols))
            
            stockManager.updateStockSymbols(combinedSymbols)
            stockManager.connect()
        }
        .onChange(of: excelManager.importedStocks) { _ in
            // 엑셀 데이터가 변경될 때마다 주식 매니저 업데이트
            let allSymbols = portfolioManager.getAllUniqueSymbols()
            let excelSymbols = excelManager.convertToStockItems().map { $0.symbol }
            let combinedSymbols = Array(Set(allSymbols + excelSymbols))
            
            stockManager.updateStockSymbols(combinedSymbols)
        }
    }
}
