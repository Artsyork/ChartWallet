//
//  UpdatedPortfolioView.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUI

struct UpdatedPortfolioView: View {
    @ObservedObject var stockManager: StockDataManager
    @ObservedObject var portfolioManager: PortfolioManager
    @StateObject private var excelManager = ExcelImportManager()
    
    @State private var showingAddPortfolio = false
    @State private var showingExcelImport = false
    @State private var selectedPortfolio: Portfolio?
    @State private var selectedStock: StockItem?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 총 자산 요약
                    PortfolioSummaryView(
                        portfolios: portfolioManager.portfolios,
                        stocks: stockManager.stocks
                    )
                    .padding(.horizontal)
                    
                    // 데이터 관리 섹션 (새로 추가)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("데이터 관리")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            // 수동 종목 추가
                            Button("수동 추가") {
                                showingAddPortfolio = true
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            
                            // 엑셀로 일괄 추가
                            Button("엑셀 가져오기") {
                                showingExcelImport = true
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            
                            Spacer()
                            
                            // 가져온 데이터 현황
                            if !excelManager.importedStocks.isEmpty {
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("엑셀 데이터")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    
                                    Text("\(excelManager.importedStocks.count)개")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal)
                    
                    // 보유 주식 목록
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("보유 주식")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text("\(portfolioManager.portfolios.count)개")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        if portfolioManager.portfolios.isEmpty {
                            EmptyPortfolioView {
                                showingAddPortfolio = true
                            }
                        } else {
                            // 컬렉션 뷰로 구성된 포트폴리오 목록
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                ForEach(portfolioManager.portfolios) { portfolio in
                                    PortfolioCardView(
                                        portfolio: portfolio,
                                        currentStock: stockManager.stocks.first { $0.symbol == portfolio.symbol }
                                    )
                                    .onTapGesture {
                                        if let stock = stockManager.stocks.first(where: { $0.symbol == portfolio.symbol }) {
                                            selectedStock = stock
                                        }
                                    }
                                    .onLongPressGesture {
                                        selectedPortfolio = portfolio
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // 가져온 엑셀 데이터 요약 (있는 경우)
                    if !excelManager.importedStocks.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("가져온 데이터")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Button("전체보기") {
                                    showingExcelImport = true
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(excelManager.importedStocks.prefix(5)) { stock in
                                        ExcelDataCardView(stock: stock)
                                            .frame(width: 160)
                                    }
                                    
                                    if excelManager.importedStocks.count > 5 {
                                        VStack {
                                            Text("+\(excelManager.importedStocks.count - 5)")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.blue)
                                            
                                            Text("더 보기")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(width: 80, height: 100)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.blue.opacity(0.1))
                                        )
                                        .onTapGesture {
                                            showingExcelImport = true
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom, 100) // 탭바 여백
            }
            .navigationTitle("내 자산")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingAddPortfolio) {
            AddPortfolioView(portfolioManager: portfolioManager)
        }
        .sheet(isPresented: $showingExcelImport) {
            XLSXCompatibleImportView(
                excelManager: excelManager,
                portfolioManager: portfolioManager
            )
            //ExcelImportView(excelManager: excelManager, portfolioManager: portfolioManager)
        }
        .sheet(item: $selectedPortfolio) { portfolio in
            EditPortfolioView(portfolio: portfolio, portfolioManager: portfolioManager)
        }
        .sheet(item: $selectedStock) { stock in
            StockDetailView(stock: stock)
        }
    }
}
