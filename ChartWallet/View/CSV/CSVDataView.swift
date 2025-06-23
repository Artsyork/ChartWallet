//
//  CSVDataView.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUI

struct CSVDataView: View {
    @ObservedObject var excelManager: ExcelImportManager
    @ObservedObject var portfolioManager: PortfolioManager
    @ObservedObject var stockManager: StockDataManager
    
    @State private var selectedStock: ExcelStockData?
    @State private var showingImportView = false
    @State private var showingFilterSheet = false
    @State private var searchText = ""
    @State private var selectedSortOption = SortOption.seq
    @State private var isAscending = true
    
    enum SortOption: String, CaseIterable {
        case seq = "순번" // 0
        case companyName = "종목명" // 1
        case currentPrice = "현재가" // 2
        case analystRating = "애널리스트 평가" // 5
        case targetPrice = "목표가" // 6
        case expectedReturn = "예상 수익률" // 7
        case uploadDate = "업로드 일시"
    }
    
    var filteredAndSortedStocks: [ExcelStockData] {
        var stocks = excelManager.importedStocks
    
        // 검색 필터
        if !searchText.isEmpty {
            stocks = stocks.filter { stock in
                stock.companyName.localizedCaseInsensitiveContains(searchText) ||
                (stock.analystRating?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // 정렬
        stocks.sort { stock1, stock2 in
            let result: Bool
            
            switch selectedSortOption {
            case .seq:
                result = stock1.seq < stock2.seq
            case .companyName:
                result = stock1.companyName < stock2.companyName
            case .currentPrice:
                let price1 = stock1.currentPrice ?? 0
                let price2 = stock2.currentPrice ?? 0
                result = price1 < price2
            case .targetPrice:
                let target1 = stock1.analystTargetPrice ?? 0
                let target2 = stock2.analystTargetPrice ?? 0
                result = target1 < target2
            case .expectedReturn:
                let return1 = stock1.expectedReturn ?? 0
                let return2 = stock2.expectedReturn ?? 0
                result = return1 < return2
            case .analystRating:
                let rating1 = stock1.analystRating ?? ""
                let rating2 = stock2.analystRating ?? ""
                result = rating1 < rating2
            case .uploadDate:
                result = stock1.uploadDate < stock2.uploadDate
            }
            
            return isAscending ? result : !result
        }
        
        return stocks
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 상단 컨트롤
                VStack(spacing: 12) {
                    // 검색바와 필터 버튼
                    HStack {
                        // 검색바
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            
                            TextField("종목명 또는 평가 검색", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                        )
                        
                        // 정렬 버튼
                        Button(action: { showingFilterSheet = true }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 통계 요약
                    if !excelManager.importedStocks.isEmpty {
                        HStack(spacing: 20) {
                            VStack {
                                Text("\(filteredAndSortedStocks.count)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Text("총 종목")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                let sectors = Set(filteredAndSortedStocks.compactMap { $0.sector })
                                Text("\(sectors.count)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Text("섹터")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                let avgReturn = filteredAndSortedStocks.compactMap { $0.expectedReturn }.average
                                Text("\(avgReturn, specifier: "%.1f")%")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(avgReturn >= 0 ? .green : .red)
                                
                                Text("평균 수익률")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        .padding(.horizontal)
                    }
                }
                .background(Color(.systemBackground))
                
                if excelManager.importedStocks.isEmpty {
                    // 빈 상태
                    EmptyCSVDataView {
                        showingImportView = true
                    }
                } else {
                    // 테이블 헤더
                    CSVTableHeaderView()
                    
                    // 데이터 테이블
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredAndSortedStocks) { stock in
                                CSVTableRowView(stock: stock)
                                    .onTapGesture {
                                        selectedStock = stock
                                    }
                                
                                Divider()
                            }
                        }
                    }
                }
            }
            .navigationTitle("CSV 데이터")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                trailing: HStack(spacing: 16) {
                    // 데이터 관리 버튼
                    Button(action: { showingImportView = true }) {
                        Image(systemName: "plus.circle")
                            .font(.title3)
                    }
                    
                    // 데이터 삭제 버튼 (데이터가 있을 때만)
                    if !excelManager.importedStocks.isEmpty {
                        Button(action: {
                            excelManager.clearImportedData()
                        }) {
                            Image(systemName: "trash")
                                .font(.title3)
                                .foregroundColor(.red)
                        }
                    }
                }
            )
        }
        .sheet(isPresented: $showingImportView) {
            SimplifiedImprovedExcelImportView(
                excelManager: excelManager,
                portfolioManager: portfolioManager
            )
        }
        .sheet(item: $selectedStock) { stock in
            CSVStockDetailView(stock: stock, portfolioManager: portfolioManager)
        }
        .actionSheet(isPresented: $showingFilterSheet) {
            ActionSheet(
                title: Text("정렬 옵션"),
                buttons: [
                    .default(Text("순번 ↑")) {
                        selectedSortOption = .seq
                        isAscending = true
                    },
                    .default(Text("순번 ↓")) {
                        selectedSortOption = .seq
                        isAscending = false
                    },
                    .default(Text("종목명 ↑")) {
                        selectedSortOption = .companyName
                        isAscending = true
                    },
                    .default(Text("종목명 ↓")) {
                        selectedSortOption = .companyName
                        isAscending = false
                    },
                    .default(Text("현재가 ↑")) {
                        selectedSortOption = .currentPrice
                        isAscending = true
                    },
                    .default(Text("현재가 ↓")) {
                        selectedSortOption = .currentPrice
                        isAscending = false
                    },
                    .default(Text("예상 수익률 ↑")) {
                        selectedSortOption = .expectedReturn
                        isAscending = true
                    },
                    .default(Text("예상 수익률 ↓")) {
                        selectedSortOption = .expectedReturn
                        isAscending = false
                    },
                    .default(Text("업로드 일시 ↑")) {
                        selectedSortOption = .uploadDate
                        isAscending = true
                    },
                    .default(Text("업로드 일시 ↓")) {
                        selectedSortOption = .uploadDate
                        isAscending = false
                    },
                    .cancel(Text("취소"))
                ]
            )
        }
    }
    
}
