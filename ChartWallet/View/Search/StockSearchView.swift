//
//  StockSearchView.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

struct StockSearchView: View {
    @ObservedObject var portfolioManager: PortfolioManager
    @ObservedObject var stockManager: StockDataManager
    @StateObject private var searchManager = StockSearchManager()
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                // 배경
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 검색 바 (상단 고정)
                    VStack(spacing: 12) {
                        // 검색 입력 필드
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 16))
                                
                                TextField("종목명 또는 심볼 검색", text: $searchText)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .focused($isSearchFocused)
                                    .onSubmit {
                                        if !searchText.isEmpty {
                                            searchManager.searchStocks(query: searchText)
                                        }
                                    }
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                        searchManager.clearSearch()
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                            
                            Button("취소") {
                                dismiss()
                            }
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        // 검색 상태 표시
                        if searchManager.isSearching {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("검색 중...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .background(Color.black)
                    
                    // 메인 콘텐츠 영역
                    if searchText.isEmpty {
                        // 검색어가 없을 때 - 가이드 화면
                        SearchGuideView(portfolioManager: portfolioManager)
                    } else {
                        // 검색 결과 영역
                        SearchResultsArea(
                            searchManager: searchManager,
                            portfolioManager: portfolioManager,
                            stockManager: stockManager,
                            onStockAdded: { symbol, name in
                                alertMessage = "\(symbol)이(가) 관심목록에 추가되었습니다."
                                showingAlert = true
                            }
                        )
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                // 화면이 나타나면 검색창에 포커스
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isSearchFocused = true
                }
            }
            .onChange(of: searchText) { newValue in
                // 실시간 검색 (디바운싱)
                if newValue.isEmpty {
                    searchManager.clearSearch()
                } else {
                    // 500ms 후에 검색 실행 (사용자 입력을 방해하지 않음)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if searchText == newValue && !newValue.isEmpty {
                            searchManager.searchStocks(query: newValue)
                        }
                    }
                }
            }
            .alert("알림", isPresented: $showingAlert) {
                Button("확인") { }
            } message: {
                Text(alertMessage)
            }
        }
        .preferredColorScheme(.dark)
    }
}


#Preview {
    StockSearchView(
        portfolioManager: PortfolioManager(),
        stockManager: StockDataManager()
    )
}
