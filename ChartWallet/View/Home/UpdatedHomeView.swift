//
//  UpdatedHomeView.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUI

struct UpdatedHomeView: View {
    @ObservedObject var stockManager: StockDataManager
    @ObservedObject var portfolioManager: PortfolioManager
    @StateObject private var excelManager = ExcelImportManager()
    
    @State private var selectedStock: StockItem?
    @State private var showingAddToWatchlist = false
    @State private var showingExcelImport = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 연결 상태 헤더
                    ConnectionHeaderView(
                        status: stockManager.connectionStatus,
                        lastAnalystUpdate: stockManager.lastAnalystUpdate,
                        nextAnalystUpdate: stockManager.nextAnalystUpdate,
                        onConnect: { stockManager.connect() },
                        onForceUpdate: { stockManager.forceUpdateAnalystData() }
                    )
                    
                    // 데이터 가져오기 섹션 (새로 추가)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("데이터 관리")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            // 엑셀 가져오기 버튼
                            Button(action: { showingExcelImport = true }) {
                                HStack {
                                    Image(systemName: "doc.badge.plus")
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("엑셀 가져오기")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                        
                                        Text("주식 데이터 업로드")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .foregroundColor(.blue)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue.opacity(0.1))
                                )
                            }
                            
                            // 가져온 데이터 현황
                            if !excelManager.importedStocks.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("가져온 데이터")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                    
                                    Text("\(excelManager.importedStocks.count)개 종목")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    
                                    Text(formatDate(excelManager.importedStocks.first?.uploadDate ?? Date()))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green.opacity(0.1))
                                )
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    // 인기 종목 섹션
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("인기 종목")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        let popularStocks = stockManager.stocks.filter { stock in
                            portfolioManager.popularStocks.contains { $0.0 == stock.symbol }
                        }.prefix(7)
                        
                        ForEach(Array(popularStocks)) { stock in
                            StockCardView(stock: stock)
                                .padding(.horizontal)
                                .onTapGesture {
                                    selectedStock = stock
                                }
                        }
                    }
                    
                    // 관심 종목 섹션
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("관심 종목")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button("편집") {
                                showingAddToWatchlist = true
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                        }
                        .padding(.horizontal)
                        
                        // 관심목록 (정렬 가능)
                        WatchlistSectionView(
                            watchlist: portfolioManager.watchlist,
                            stocks: stockManager.stocks,
                            portfolioManager: portfolioManager,
                            onStockSelected: { stock in
                                selectedStock = stock
                            }
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 100) // 탭바 여백
            }
            .navigationTitle("홈")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedStock) { stock in
            StockDetailView(stock: stock)
        }
        .sheet(isPresented: $showingAddToWatchlist) {
            WatchlistEditView(portfolioManager: portfolioManager)
        }
        .sheet(isPresented: $showingExcelImport) {
            SimplifiedImprovedExcelImportView(
                excelManager: excelManager,
                portfolioManager: portfolioManager
            )
//            ImprovedExcelImportView(
//                excelManager: excelManager,
//                portfolioManager: portfolioManager
//            )
            //ExcelImportView(excelManager: excelManager, portfolioManager: portfolioManager)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}
