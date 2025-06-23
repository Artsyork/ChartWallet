//
//  ExcelImportManager.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import Foundation

// MARK: - Excel Import Manager
class ExcelImportManager: ObservableObject {
    @Published var importedStocks: [ExcelStockData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let storageKey = "ImportedExcelStocks"
    
    init() {
        loadStoredData()
    }
    
    /// XLSX 호환 파일 파싱 (실제 사용하는 메서드)
    func parseXLSXCompatibleFile(fileURL: URL, completion: @escaping (Result<[ExcelStockData], Error>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        print("📊 XLSX 호환 파싱 시작: \(fileURL.lastPathComponent)")
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                guard fileURL.startAccessingSecurityScopedResource() else {
                    throw ExcelParsingError.permissionDenied
                }
                
                defer {
                    fileURL.stopAccessingSecurityScopedResource()
                }
                
                let parsedStocks = try XLSXCompatibleParsingService.parseExcelFile(at: fileURL)
                
                DispatchQueue.main.async {
                    self?.isLoading = false
                    completion(.success(parsedStocks))
                }
            } catch {
                print("❌ XLSX 파싱 오류: \(error)")
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// 파싱된 데이터를 앱에 저장
    func saveImportedData(_ stocks: [ExcelStockData]) {
        importedStocks = stocks
        saveToStorage()
    }
    
    /// 데이터를 UserDefaults에 저장
    private func saveToStorage() {
        if let encoded = try? JSONEncoder().encode(importedStocks) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    /// 저장된 데이터 로드
    private func loadStoredData() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([ExcelStockData].self, from: data) else { return }
        importedStocks = decoded
    }
    
    /// 데이터 삭제
    func clearImportedData() {
        importedStocks.removeAll()
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    
    /// StockItem으로 변환 (새로운 모델에 맞춤)
    func convertToStockItems() -> [StockItem] {
        return importedStocks.compactMap { excelStock in
            // 회사명에서 주식 심볼 추출 시도
            let symbol = extractSymbolFromCompanyName(excelStock.companyName)
            guard !symbol.isEmpty else { return nil }
            
            var stockItem = StockItem(symbol: symbol, name: excelStock.companyName)
            
            // 현재가 설정 (통합된 가격 사용)
            if let price = excelStock.currentPrice {
                switch excelStock.country {
                case .USA:
                    stockItem.currentPrice = price
                case .KR:
                    // 원화를 달러로 환산 (대략적인 환율)
                    stockItem.currentPrice = price / 1300.0
                }
            }
            
            // 애널리스트 데이터 설정
            if let rating = excelStock.analystRating,
               let targetPrice = excelStock.analystTargetPrice {
                stockItem.analystData = AnalystRecommendation(
                    symbol: symbol,
                    analystRatingsStrongBuy: rating.contains("Strong Buy") ? 1 : nil,
                    analystRatingsBuy: rating.contains("Buy") ? 1 : nil,
                    analystRatingsHold: rating.contains("Hold") ? 1 : nil,
                    analystRatingsSell: rating.contains("Sell") ? 1 : nil,
                    analystRatingsStrongSell: rating.contains("Strong Sell") ? 1 : nil,
                    analystTargetPrice: targetPrice,
                    analystTargetPriceHigh: nil,
                    analystTargetPriceLow: nil
                )
            }
            
            return stockItem
        }
    }
    
    /// 회사명에서 주식 심볼 추출 (간단한 매핑)
    private func extractSymbolFromCompanyName(_ companyName: String) -> String {
        let companyMappings: [String: String] = [
            "Apple": "AAPL",
            "Microsoft": "MSFT",
            "Google": "GOOGL",
            "Alphabet": "GOOGL",
            "Amazon": "AMZN",
            "Tesla": "TSLA",
            "Meta": "META",
            "Facebook": "META",
            "NVIDIA": "NVDA",
            "Netflix": "NFLX"
        ]
        
        for (company, symbol) in companyMappings {
            if companyName.localizedCaseInsensitiveContains(company) {
                return symbol
            }
        }
        
        // 매핑되지 않은 경우 회사명의 첫 4글자를 대문자로 변환
        let cleanName = companyName.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "Inc.", with: "")
            .replacingOccurrences(of: "Corp.", with: "")
            .replacingOccurrences(of: "LLC", with: "")
        return String(cleanName.prefix(4)).uppercased()
    }
    
    /// 샘플 데이터 생성 (ExcelStockDataKr 모델에 맞춤)
    func generateSampleData() -> [ExcelStockData] {
        return [
            ExcelStockData(
                seq: 1,
                companyName: "삼성전자",
                currentPrice: 72000,
                sector: "기술",
                industry: "반도체",
                analystRating: "80000", // 목표가 (원 단위)
                analystTargetPrice: 85.0, // 평가 (수치값)
                expectedReturn: 11.49,
                week52High: 85000,
                week52Low: 65000,
                allTimeHigh: 95000,
                country: .KR
            ),
            ExcelStockData(
                seq: 2,
                companyName: "SK하이닉스",
                currentPrice: 135000,
                sector: "기술",
                industry: "메모리",
                analystRating: "160000", // 목표가 (원 단위)
                analystTargetPrice: 90.0, // 평가 (수치값)
                expectedReturn: 18.52,
                week52High: 165000,
                week52Low: 120000,
                allTimeHigh: 175000,
                country: .KR
            ),
            ExcelStockData(
                seq: 3,
                companyName: "LG에너지솔루션",
                currentPrice: 485000,
                sector: "에너지",
                industry: "배터리",
                analystRating: "550000", // 목표가 (원 단위)
                analystTargetPrice: 75.0, // 평가 (수치값)
                expectedReturn: 13.40,
                week52High: 520000,
                week52Low: 450000,
                allTimeHigh: 590000,
                country: .KR
            ),
            ExcelStockData(
                seq: 4,
                companyName: "NAVER",
                currentPrice: 195000,
                sector: "기술",
                industry: "인터넷",
                analystRating: "220000", // 목표가 (원 단위)
                analystTargetPrice: 70.0, // 평가 (수치값)
                expectedReturn: 12.82,
                week52High: 210000,
                week52Low: 175000,
                allTimeHigh: 245000,
                country: .KR
            ),
            ExcelStockData(
                seq: 5,
                companyName: "카카오",
                currentPrice: 48500,
                sector: "기술",
                industry: "모바일",
                analystRating: "65000", // 목표가 (원 단위)
                analystTargetPrice: 60.0, // 평가 (수치값)
                expectedReturn: 34.02,
                week52High: 52000,
                week52Low: 42000,
                allTimeHigh: 78000,
                country: .KR
            )
        ]
    }
    
    /// 샘플 데이터로 테스트
    func loadSampleData() {
        let sampleStocks = generateSampleData()
        saveImportedData(sampleStocks)
    }
    
}
