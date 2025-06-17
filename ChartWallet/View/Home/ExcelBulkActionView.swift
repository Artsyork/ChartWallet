//
//  ExcelBulkActionView.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUI

struct ExcelBulkActionView: View {
    @ObservedObject var excelManager: ExcelImportManager
    @ObservedObject var portfolioManager: PortfolioManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedStocks: Set<UUID> = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 선택 상태 표시
                HStack {
                    Text("선택된 종목: \(selectedStocks.count)개")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(selectedStocks.count == excelManager.importedStocks.count ? "전체 해제" : "전체 선택") {
                        if selectedStocks.count == excelManager.importedStocks.count {
                            selectedStocks.removeAll()
                        } else {
                            selectedStocks = Set(excelManager.importedStocks.map { $0.id })
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal)
                
                // 종목 목록
                List(excelManager.importedStocks) { stock in
                    HStack {
                        Button(action: {
                            if selectedStocks.contains(stock.id) {
                                selectedStocks.remove(stock.id)
                            } else {
                                selectedStocks.insert(stock.id)
                            }
                        }) {
                            Image(systemName: selectedStocks.contains(stock.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedStocks.contains(stock.id) ? .blue : .secondary)
                        }
                        
                        ExcelStockRowView(stock: stock)
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
                
                // 액션 버튼들
                VStack(spacing: 12) {
                    Button("선택된 종목을 관심목록에 추가") {
                        addSelectedToWatchlist()
                    }
                    .disabled(selectedStocks.isEmpty)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedStocks.isEmpty ? Color.gray.opacity(0.3) : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .fontWeight(.semibold)
                    
                    Button("선택된 종목을 포트폴리오에 추가") {
                        addSelectedToPortfolio()
                    }
                    .disabled(selectedStocks.isEmpty)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedStocks.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .fontWeight(.semibold)
                }
                .padding()
            }
            .navigationTitle("일괄 처리")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("취소") {
                    dismiss()
                }
            )
        }
        .alert("알림", isPresented: $showingAlert) {
            Button("확인") {
                if alertMessage.contains("추가되었습니다") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func addSelectedToWatchlist() {
        let selectedStocksData = excelManager.importedStocks.filter { selectedStocks.contains($0.id) }
        var addedCount = 0
        
        for stock in selectedStocksData {
            let symbol = extractSymbol(from: stock.companyName)
            if !portfolioManager.watchlist.contains(where: { $0.symbol == symbol }) {
                portfolioManager.addToWatchlist(symbol: symbol, name: stock.companyName)
                addedCount += 1
            }
        }
        
        alertMessage = "\(addedCount)개 종목이 관심목록에 추가되었습니다."
        showingAlert = true
    }
    
    private func addSelectedToPortfolio() {
        alertMessage = "포트폴리오 추가 기능은 수량과 매수가 정보가 필요하여 개별 추가를 권장합니다."
        showingAlert = true
    }
    
    private func extractSymbol(from companyName: String) -> String {
        // 간단한 심볼 추출 로직
        let cleanName = companyName.replacingOccurrences(of: " ", with: "")
                                  .replacingOccurrences(of: "Inc.", with: "")
                                  .replacingOccurrences(of: "Corp.", with: "")
        return String(cleanName.prefix(4)).uppercased()
    }
}
