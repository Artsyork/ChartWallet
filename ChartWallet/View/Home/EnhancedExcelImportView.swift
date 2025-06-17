//
//  EnhancedExcelImportView.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUI

struct EnhancedExcelImportView: View {
    @ObservedObject var excelManager: ExcelImportManager
    @ObservedObject var portfolioManager: PortfolioManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingFilePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSampleDataOption = false
    
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
                    
                    Text("주식 데이터가 포함된 엑셀 파일을 업로드하거나\n샘플 데이터로 테스트해보세요")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // 파일 형식 안내 (접을 수 있는 형태)
                DisclosureGroup("파일 형식 안내") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("지원 파일 형식:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• Excel 파일 (.xlsx, .xls)")
                            Text("• CSV 파일 (.csv)")
                            Text("• 첫 번째 행은 헤더로 처리됩니다")
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        
                        Text("컬럼 순서:")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.top, 8)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("A: 순번, B: 회사명, C: 현재가(원), D: 현재가(달러)")
                            Text("E: 섹터, F: 산업, G: 애널리스트 평가, H: 목표가")
                            Text("I: 예상 수익률, J: 52주 최고가, K: 52주 최저가, L: ATH")
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                // 액션 버튼들
                VStack(spacing: 12) {
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
                    
                    // 샘플 데이터 버튼
                    Button("샘플 데이터로 테스트") {
                        showingSampleDataOption = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .fontWeight(.semibold)
                }
                
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
                    ExcelDataSummaryView(
                        excelManager: excelManager,
                        portfolioManager: portfolioManager,
                        onAddToWatchlist: addToWatchlist
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
            allowedContentTypes: [.spreadsheet, .commaSeparatedText, .data],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result)
        }
        .alert("샘플 데이터 로드", isPresented: $showingSampleDataOption) {
            Button("취소", role: .cancel) { }
            Button("로드") {
                excelManager.loadSampleData()
                alertMessage = "샘플 데이터가 로드되었습니다."
                showingAlert = true
            }
        } message: {
            Text("샘플 주식 데이터를 로드하시겠습니까? (Apple, Microsoft, Tesla)")
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
