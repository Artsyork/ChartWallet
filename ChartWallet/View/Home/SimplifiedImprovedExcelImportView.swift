//
//  SimplifiedImprovedExcelImportView.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct SimplifiedImprovedExcelImportView: View {
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
                // 안내 섹션 (XLSX 지원 강조)
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
                    
                    Text("스마트 파일 가져오기")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("XLSX, XLS, CSV 파일을 자동으로 감지하여 처리합니다\n한국어-영어 혼합 데이터를 안전하게 지원합니다")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // 지원 파일 형식 안내
                VStack(alignment: .leading, spacing: 8) {
                    Text("🎯 지원하는 파일 형식")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        FeatureRow(
                            icon: "checkmark.circle.fill",
                            color: .green,
                            text: "CSV 파일 (.csv) - 권장 형식"
                        )
                        
                        FeatureRow(
                            icon: "doc.text",
                            color: .blue,
                            text: "Excel 파일 (.xlsx, .xls) - 자동 감지 및 안내"
                        )
                        
                        FeatureRow(
                            icon: "icloud",
                            color: .mint,
                            text: "iCloud Drive, Google Drive 등"
                        )
                        
                        FeatureRow(
                            icon: "globe",
                            color: .orange,
                            text: "한국어-영어 혼합 데이터"
                        )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                // 파일 선택 방법 안내
                VStack(alignment: .leading, spacing: 8) {
                    Text("📂 파일 가져오는 방법")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        StepRow(number: "1", text: "아래 '파일 선택' 버튼을 누르세요")
                        StepRow(number: "2", text: "파일 앱에서 Excel 또는 CSV 파일을 선택하세요")
                        StepRow(number: "3", text: "파일 형식이 자동으로 감지되어 처리됩니다")
                        
                        HStack(alignment: .top, spacing: 8) {
                            Text("💡")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            Text("XLSX 파일의 경우 CSV 변환 가이드를 제공합니다")
                                .foregroundColor(.blue)
                        }
                        .font(.caption)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
                
                // Excel → CSV 변환 팁
                DisclosureGroup("💡 Excel → CSV 변환 팁") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("• Excel에서 '다른 이름으로 저장' → CSV 선택")
                        Text("• Google Sheets에서 '파일' → '다운로드' → CSV")
                        Text("• 한글 깨짐 방지: UTF-8 인코딩 선택")
                        Text("• 첫 번째 행에 헤더(컬럼명) 포함 필수")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.green.opacity(0.05))
                .cornerRadius(8)
                
                // 액션 버튼들
                VStack(spacing: 12) {
                    Button("파일 선택") {
                        showingFilePicker = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .fontWeight(.semibold)
                    
                    Button("샘플 데이터로 테스트") {
                        loadSampleData()
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
                    VStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("스마트 파일 분석 중...")
                            .font(.callout)
                            .fontWeight(.medium)
                        
                        Text("파일 형식을 자동으로 감지하고 최적의 방법으로 처리합니다")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // 기존 데이터 표시
                if !excelManager.importedStocks.isEmpty {
                    ImportedDataSummaryView(
                        excelManager: excelManager,
                        portfolioManager: portfolioManager,
                        onAddToWatchlist: addToWatchlist
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("스마트 데이터 가져오기")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("닫기") {
                    dismiss()
                }
            )
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [
                .commaSeparatedText,
                .delimitedText,
                .spreadsheet,
                .data // 모든 파일 허용하여 자동 감지
            ],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result)
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            if alertTitle.contains("Excel 파일") || alertTitle.contains("형식 감지") {
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
    
    // MARK: - 파일 선택 처리 (업데이트됨)
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let fileURL = urls.first else { return }
            
            // 파일 접근 권한 확인
            guard fileURL.startAccessingSecurityScopedResource() else {
                alertTitle = "파일 접근 오류"
                alertMessage = "파일에 접근할 수 없습니다. 다시 시도해주세요."
                showingAlert = true
                return
            }
            
            defer {
                fileURL.stopAccessingSecurityScopedResource()
            }
            
            // XLSX 호환 파싱 함수 사용
            excelManager.parseXLSXCompatibleFile(fileURL: fileURL) { parseResult in
                switch parseResult {
                case .success(let stocks):
                    if stocks.isEmpty {
                        alertTitle = "데이터 없음"
                        alertMessage = "파일에서 유효한 주식 데이터를 찾을 수 없습니다.\n\n• 파일 형식이 올바른지 확인해주세요\n• 첫 번째 행에 헤더가 있는지 확인해주세요\n• 데이터가 쉼표나 탭으로 구분되어 있는지 확인해주세요"
                    } else {
                        excelManager.saveImportedData(stocks)
                        alertTitle = "성공! 🎉"
                        alertMessage = "\(stocks.count)개 종목 데이터를 성공적으로 가져왔습니다!"
                    }
                    showingAlert = true
                    
                case .failure(let error):
                    // XLSX 전용 에러 처리
                    if let xlsxError = error as? XLSXError {
                        alertTitle = "Excel 파일 형식 감지"
                        alertMessage = xlsxError.localizedDescription + "\n\n" + (xlsxError.recoverySuggestion ?? "")
                    } else if let excelError = error as? ExcelParsingError {
                        alertTitle = "파일 처리 오류"
                        alertMessage = excelError.localizedDescription
                        if let suggestion = excelError.recoverySuggestion {
                            alertMessage += "\n\n💡 해결 방법:\n" + suggestion
                        }
                    } else {
                        alertTitle = "파일 처리 오류"
                        alertMessage = """
                        파일을 처리할 수 없습니다.
                        
                        오류: \(error.localizedDescription)
                        
                        💡 해결 방법:
                        • Excel 파일을 CSV로 저장 후 재시도
                        • 파일이 손상되지 않았는지 확인
                        • 다른 형식으로 저장 후 재시도
                        """
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
        alertTitle = "샘플 데이터 로드 완료"
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

#Preview {
    SimplifiedImprovedExcelImportView(
        excelManager: ExcelImportManager(),
        portfolioManager: PortfolioManager()
    )
}
