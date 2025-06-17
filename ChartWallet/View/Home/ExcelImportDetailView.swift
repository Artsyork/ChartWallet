//
//  ExcelImportDetailView.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUI

struct ExcelImportDetailView: View {
    @ObservedObject var excelManager: ExcelImportManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 통계 요약
                HStack(spacing: 20) {
                    VStack {
                        Text("\(excelManager.importedStocks.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("총 종목")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("\(Set(excelManager.importedStocks.compactMap { $0.sector }).count)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("섹터")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        let avgReturn = excelManager.importedStocks.compactMap { $0.expectedReturn }.average
                        Text("\(avgReturn, specifier: "%.1f")%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(avgReturn >= 0 ? .green : .red)
                        
                        Text("평균 수익률")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
                
                // 데이터 목록
                List(excelManager.importedStocks) { stock in
                    ExcelStockRowView(stock: stock)
                        .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
            }
            .padding()
            .navigationTitle("가져온 데이터")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("닫기") {
                    dismiss()
                }
            )
        }
    }
}
