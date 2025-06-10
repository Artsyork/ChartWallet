//
//  PortfolioView.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

struct PortfolioView: View {
    @ObservedObject var stockManager: StockDataManager
    @ObservedObject var portfolioManager: PortfolioManager
    @State private var showingAddPortfolio = false
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
                    
                    // 보유 주식 목록
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("보유 주식")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button("내 종목 추가하기") {
                                showingAddPortfolio = true
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                        }
                        .padding(.horizontal)
                        
                        if portfolioManager.portfolios.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "briefcase")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary)
                                
                                Text("보유한 주식이 없습니다")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("'내 종목 추가하기' 버튼을 눌러\n첫 번째 주식을 추가해보세요")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
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
                }
                .padding(.bottom, 100) // 탭바 여백
            }
            .navigationTitle("내 자산")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingAddPortfolio) {
            AddPortfolioView(portfolioManager: portfolioManager)
        }
        .sheet(item: $selectedPortfolio) { portfolio in
            EditPortfolioView(portfolio: portfolio, portfolioManager: portfolioManager)
        }
        .sheet(item: $selectedStock) { stock in
            StockDetailView(stock: stock)
        }
    }
}

#Preview {
    PortfolioView(
        stockManager: StockDataManager(),
        portfolioManager: PortfolioManager()
    )
}
