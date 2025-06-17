//
//  ExcelImportView.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ExcelImportView: View {
    @ObservedObject var excelManager: ExcelImportManager
    @ObservedObject var portfolioManager: PortfolioManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingFilePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var importedStocks: [ExcelStockData] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 안내 섹션
                VStack(spacing: 12) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    
                    Text("엑셀 파일 가져오기")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("주식 데이터가 포함된 엑셀 파일을 업로드하세요")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // 파일 형식 안내
                VStack(alignment: .leading, spacing: 8) {
                    Text("파일 형식 안내")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• 엑셀 파일 (.xlsx, .xls)")
                        Text("• 첫 번째 행은 헤더")
                        Text("• 다음 컬럼 순서를 맞춰주세요:")
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("  A: 순번")
                            Text("  B: 회사명")
                            Text("  C: 현재가(원)")
                            Text("  D: 현재가(달러)")
                            Text("  E: 섹터")
                            Text("  F: 산업")
                            Text("  G: 애널리스트 평가")
                            Text("  H: 목표가")
                            Text("  I: 예상 수익률")
                            Text("  J: 52주 최고가")
                            Text("  K: 52주 최저가")
                            Text("  L: ATH(All-Time High)")
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                // 파일 선택 버튼
                Button("엑셀 파일 선택") {
                    showingFilePicker = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .fontWeight(.semibold)
                
                // 로딩 상태
                if excelManager.isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("파일 처리 중...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 기존 데이터 표시
                if !excelManager.importedStocks.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("가져온 데이터")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("\(excelManager.importedStocks.count)개 종목")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(excelManager.importedStocks.prefix(5)) { stock in
                                    ExcelStockRowView(stock: stock)
                                }
                                
                                if excelManager.importedStocks.count > 5 {
                                    Text("... 및 \(excelManager.importedStocks.count - 5)개 더")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.vertical, 8)
                                }
                            }
                        }
                        .frame(maxHeight: 300)
                        
                        HStack(spacing: 12) {
                            Button("관심목록에 추가") {
                                addToWatchlist()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            
                            Button("데이터 삭제") {
                                excelManager.clearImportedData()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("데이터 가져오기")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("닫기") {
                    dismiss()
                }
            )
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.spreadsheet, .commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result)
        }
        .alert("알림", isPresented: $showingAlert) {
            Button("확인") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let fileURL = urls.first else { return }
            
            excelManager.parseExcelFile(fileURL: fileURL) { parseResult in
                switch parseResult {
                case .success(let stocks):
                    excelManager.saveImportedData(stocks)
                    alertMessage = "\(stocks.count)개 종목 데이터를 성공적으로 가져왔습니다."
                    showingAlert = true
                    
                case .failure(let error):
                    alertMessage = "파일 처리 중 오류가 발생했습니다: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
            
        case .failure(let error):
            alertMessage = "파일 선택 중 오류가 발생했습니다: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func addToWatchlist() {
        let stockItems = excelManager.convertToStockItems()
        var addedCount = 0
        
        for stockItem in stockItems {
            // 중복 확인 후 추가
            if !portfolioManager.watchlist.contains(where: { $0.symbol == stockItem.symbol }) {
                portfolioManager.addToWatchlist(symbol: stockItem.symbol, name: stockItem.name)
                addedCount += 1
            }
        }
        
        alertMessage = "\(addedCount)개 종목이 관심목록에 추가되었습니다."
        showingAlert = true
    }
}
