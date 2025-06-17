//
//  XLSXCompatibleImportView.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUICore
import SwiftUI

// MARK: - XLSX 호환 Import View
struct XLSXCompatibleImportView: View {
    @ObservedObject var excelManager: ExcelImportManager
    @ObservedObject var portfolioManager: PortfolioManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingFilePicker = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingCSVGuide = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // XLSX 지원 헤더
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "doc.text")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                        Image(systemName: "arrow.right")
                            .foregroundColor(.secondary)
                        Image(systemName: "tablecells")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                    .font(.title)
                    
                    Text("Excel/CSV 파일 가져오기")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("XLSX, XLS, CSV 파일을 자동으로 감지하여 처리합니다")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // 지원 형식 안내
                VStack(alignment: .leading, spacing: 8) {
                    Text("✅ 지원하는 파일 형식")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("CSV 파일 (.csv) - 권장 형식")
                        }
                        
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("Excel 파일 (.xlsx, .xls) - 자동 변환")
                        }
                        
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.mint)
                            Text("한국어-영어 혼합 데이터")
                        }
                    }
                    .font(.caption)
                }
                .padding()
                .background(Color.green.opacity(0.05))
                .cornerRadius(12)
                
                // CSV 변환 가이드
                DisclosureGroup("Excel → CSV 변환 방법") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("📊 Excel에서:")
                            .fontWeight(.semibold)
                        Text("1. 파일 → 다른 이름으로 저장")
                        Text("2. 형식: CSV(쉼표로 구분) 선택")
                        Text("3. UTF-8 인코딩 권장")
                        
                        Text("🌐 Google Sheets에서:")
                            .fontWeight(.semibold)
                            .padding(.top, 8)
                        Text("1. 파일 → 다운로드")
                        Text("2. CSV(.csv) 선택")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(8)
                
                // 액션 버튼들
                VStack(spacing: 12) {
                    Button("파일 선택하기") {
                        showingFilePicker = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .fontWeight(.semibold)
                    
                    Button("샘플 데이터 테스트") {
                        loadSampleData()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .fontWeight(.semibold)
                }
                
                // 로딩 상태
                if excelManager.isLoading {
                    VStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("파일 분석 중...")
                            .font(.callout)
                            .fontWeight(.medium)
                        
                        Text("파일 형식을 자동 감지하고 있습니다")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // 결과 표시
                if !excelManager.importedStocks.isEmpty {
                    VStack(spacing: 12) {
                        Text("📊 가져온 데이터: \(excelManager.importedStocks.count)개 종목")
                            .font(.headline)
                        
                        Button("관심목록에 추가") {
                            addToWatchlist()
                        }
                        .padding()
                        .background(Color.mint)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color.mint.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Excel 파일 가져오기")
            .navigationBarItems(trailing: Button("닫기") { dismiss() })
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.data],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result)
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            if alertTitle.contains("Excel 파일") {
                Button("변환 방법 보기") {
                    showingCSVGuide = true
                }
                Button("확인") { }
            } else {
                Button("확인") { }
            }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingCSVGuide) {
            CSVConversionGuideView()
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let fileURL = urls.first else { return }
            
            excelManager.parseXLSXCompatibleFile(fileURL: fileURL) { parseResult in
                switch parseResult {
                case .success(let stocks):
                    if stocks.isEmpty {
                        alertTitle = "데이터 없음"
                        alertMessage = "파일에서 유효한 데이터를 찾을 수 없습니다.\n파일 형식과 내용을 확인해주세요."
                    } else {
                        excelManager.saveImportedData(stocks)
                        alertTitle = "성공! 🎉"
                        alertMessage = "\(stocks.count)개 종목 데이터를 성공적으로 가져왔습니다!"
                    }
                    showingAlert = true
                    
                case .failure(let error):
                    if let xlsxError = error as? XLSXError {
                        alertTitle = "Excel 파일 형식 감지"
                        alertMessage = xlsxError.localizedDescription + "\n\n" + (xlsxError.recoverySuggestion ?? "")
                    } else {
                        alertTitle = "파일 처리 오류"
                        alertMessage = "파일을 처리할 수 없습니다.\n\n오류: \(error.localizedDescription)"
                    }
                    showingAlert = true
                }
            }
            
        case .failure(let error):
            alertTitle = "파일 선택 오류"
            alertMessage = "파일 선택 중 오류가 발생했습니다: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func loadSampleData() {
        excelManager.loadSampleData()
        alertTitle = "샘플 데이터 로드"
        alertMessage = "테스트용 샘플 데이터가 로드되었습니다."
        showingAlert = true
    }
    
    private func addToWatchlist() {
        let stockItems = excelManager.convertToStockItems()
        var addedCount = 0
        
        for stockItem in stockItems {
            if !portfolioManager.watchlist.contains(where: { $0.symbol == stockItem.symbol }) {
                portfolioManager.addToWatchlist(symbol: stockItem.symbol, name: stockItem.name)
                addedCount += 1
            }
        }
        
        alertTitle = "관심목록 추가 완료"
        alertMessage = "\(addedCount)개 종목이 관심목록에 추가되었습니다."
        showingAlert = true
    }
}
