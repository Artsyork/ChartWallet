//
//  StockSearchManager.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import Foundation
import Combine

class StockSearchManager: ObservableObject {
    @Published var searchResults: [StockSearchResult] = []
    @Published var isSearching = false
    @Published var searchError: String?
    
    private let fmpAPIKey = BaseURL.FMP_API_KEY.url
    private var searchCancellable: AnyCancellable?
    
    struct StockSearchResult: Identifiable {
        let id = UUID()
        let symbol: String
        let name: String
        let currency: String?
        let stockExchange: String?
        let exchangeShortName: String?
        
        init(from response: StockSearch_API.Response) {
            self.symbol = response.symbol
            self.name = response.name
            self.currency = response.currency
            self.stockExchange = response.stockExchange
            self.exchangeShortName = response.exchangeShortName
        }
    }
    
    func searchStocks(query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        guard !fmpAPIKey.isEmpty else {
            searchError = "API 키가 설정되지 않았습니다"
            return
        }
        
        // 이전 검색 취소
        searchCancellable?.cancel()
        
        isSearching = true
        searchError = nil
        
        let request = StockSearch_API.Request(
            query: query.trimmingCharacters(in: .whitespacesAndNewlines),
            limit: 20,
            apikey: fmpAPIKey
        )
        
        let urlString = "\(StockSearch_API.endPoint)?query=\(request.query)&limit=\(request.limit)&apikey=\(request.apikey)"
        
        guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedString) else {
            searchError = "잘못된 검색어입니다"
            isSearching = false
            return
        }
        
        print("🔍 주식 검색: \(query)")
        print("📡 API 요청: \(url.absoluteString)")
        
        searchCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [StockSearch_API.Response].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    
                    self.isSearching = false
                    
                    switch completion {
                    case .finished:
                        print("✅ 검색 완료")
                    case .failure(let error):
                        print("❌ 검색 실패: \(error)")
                        self.searchError = "검색 중 오류가 발생했습니다"
                        self.searchResults = []
                    }
                },
                receiveValue: { [weak self] responses in
                    guard let self = self else { return }
                    
                    print("📊 검색 결과: \(responses.count)개")
                    
                    // 미국 주식 시장 우선 필터링
                    let filteredResults = responses.filter { response in
                        let exchange = response.exchangeShortName?.uppercased() ?? ""
                        return ["NASDAQ", "NYSE", "AMEX", "OTC", "OTCQB", "OTCQX"].contains(exchange)
                    }
                    
                    self.searchResults = filteredResults.map { StockSearchResult(from: $0) }
                    
                    if self.searchResults.isEmpty && !responses.isEmpty {
                        print("ℹ️ 미국 주식 시장 결과가 없어서 전체 결과를 표시합니다")
                        self.searchResults = responses.map { StockSearchResult(from: $0) }
                    }
                    
                    print("✅ 최종 검색 결과: \(self.searchResults.count)개")
                }
            )
    }
    
    func clearSearch() {
        searchResults = []
        searchError = nil
        searchCancellable?.cancel()
    }
    
    deinit {
        searchCancellable?.cancel()
    }
}
