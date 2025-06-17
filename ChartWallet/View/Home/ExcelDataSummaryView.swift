//
//  ExcelDataSummaryView.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUI

struct ExcelDataSummaryView: View {
    @ObservedObject var excelManager: ExcelImportManager
    @ObservedObject var portfolioManager: PortfolioManager
    let onAddToWatchlist: () -> Void
    
    @State private var showingDetailView = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("가져온 데이터")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("전체보기") {
                    showingDetailView = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            // 통계 요약
            HStack(spacing: 16) {
                VStack {
                    Text("\(excelManager.importedStocks.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("총 종목")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    let sectors = Set(excelManager.importedStocks.compactMap { $0.sector })
                    Text("\(sectors.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("섹터")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    let avgReturn = excelManager.importedStocks.compactMap { $0.expectedReturn }.average
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
            
            // 미리보기 (상위 3개)
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(excelManager.importedStocks.prefix(3)) { stock in
                        ExcelStockRowView(stock: stock)
                    }
                    
                    if excelManager.importedStocks.count > 3 {
                        Text("... 및 \(excelManager.importedStocks.count - 3)개 더")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    }
                }
            }
            .frame(maxHeight: 200)
            
            // 액션 버튼들
            HStack(spacing: 12) {
                Button("관심목록 추가") {
                    onAddToWatchlist()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                .font(.caption)
                
                Button("데이터 삭제") {
                    excelManager.clearImportedData()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                .font(.caption)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .sheet(isPresented: $showingDetailView) {
            ExcelImportDetailView(excelManager: excelManager)
        }
    }
}
