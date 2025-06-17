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
    
    /// 엑셀 파일에서 데이터 파싱
    // Excel 파일 파싱 로직
    // 컬럼 매핑:
    // A: seq, B: 회사명, C: 현재가(원), D: 현재가(달러), E: 섹터, F: 산업
    // G: 애널리스트 평가, H: 목표가, I: 예상 수익률, J: 52주 최고가, K: 52주 최저가, L: ATH
    func parseExcelFile(fileURL: URL, completion: @escaping (Result<[ExcelStockData], Error>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let parsedStocks = try ExcelParsingService.parseExcelFile(at: fileURL)
                
                DispatchQueue.main.async {
                    self?.isLoading = false
                    completion(.success(parsedStocks))
                }
            } catch {
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
    
    /// StockItem으로 변환 (기존 시스템과 통합용)
    func convertToStockItems() -> [StockItem] {
        return importedStocks.compactMap { excelStock in
            // 회사명에서 주식 심볼 추출 시도 (예: "Apple Inc." -> "AAPL")
            let symbol = extractSymbolFromCompanyName(excelStock.companyName)
            guard !symbol.isEmpty else { return nil }
            
            var stockItem = StockItem(symbol: symbol, name: excelStock.companyName)
            
            // 현재가 설정 (달러 우선, 없으면 원화를 달러로 환산)
            if let usdPrice = excelStock.currentPriceUSD {
                stockItem.currentPrice = usdPrice
            } else if let krwPrice = excelStock.currentPriceKRW {
                // 간단한 환율 적용 (실제로는 실시간 환율 API 사용 권장)
                stockItem.currentPrice = krwPrice / 1300.0 // 대략적인 환율
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
    
    /// 샘플 데이터 생성 (테스트용)
    func generateSampleData() -> [ExcelStockData] {
        return [
            ExcelStockData(
                seq: 1,
                companyName: "Apple Inc.",
                currentPriceKRW: 240000,
                currentPriceUSD: 180.50,
                sector: "Technology",
                industry: "Consumer Electronics",
                analystRating: "Strong Buy",
                analystTargetPrice: 200.0,
                expectedReturn: 10.8,
                week52High: 198.23,
                week52Low: 164.08,
                allTimeHigh: 198.23
            ),
            ExcelStockData(
                seq: 2,
                companyName: "Microsoft Corporation",
                currentPriceKRW: 500000,
                currentPriceUSD: 380.25,
                sector: "Technology",
                industry: "Software",
                analystRating: "Buy",
                analystTargetPrice: 420.0,
                expectedReturn: 10.4,
                week52High: 384.30,
                week52Low: 309.45,
                allTimeHigh: 384.30
            ),
            ExcelStockData(
                seq: 3,
                companyName: "Tesla Inc.",
                currentPriceKRW: 325000,
                currentPriceUSD: 250.75,
                sector: "Consumer Cyclical",
                industry: "Auto Manufacturers",
                analystRating: "Hold",
                analystTargetPrice: 275.0,
                expectedReturn: 9.7,
                week52High: 299.29,
                week52Low: 138.80,
                allTimeHigh: 409.97
            )
        ]
    }
    
    /// 샘플 데이터로 테스트
    func loadSampleData() {
        let sampleStocks = generateSampleData()
        saveImportedData(sampleStocks)
    }
    
}

// MARK: - Enhanced Excel Import Manager

extension ExcelImportManager {
    
    /// XLSX 호환 파일 파싱
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
    
}
