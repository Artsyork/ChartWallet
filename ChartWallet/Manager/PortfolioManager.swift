//
//  PortfolioManager.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import Foundation

class PortfolioManager: ObservableObject {
    @Published var portfolios: [Portfolio] = []
    @Published var watchlist: [WatchlistItem] = []
    
    private let portfolioKey = "PortfolioData"
    private let watchlistKey = "WatchlistData"
    
    // 인기 종목 (최대 7개)
    let popularStocks = [
        ("AAPL", "Apple Inc."),
        ("GOOGL", "Alphabet Inc."),
        ("MSFT", "Microsoft Corp."),
        ("TSLA", "Tesla Inc."),
        ("AMZN", "Amazon.com Inc."),
        ("NVDA", "NVIDIA Corp."),
        ("META", "Meta Platforms")
    ]
    
    init() {
        loadPortfolios()
        loadWatchlist()
        
        // 관심목록이 비어있으면 인기 종목으로 초기화
        if watchlist.isEmpty {
            initializeWatchlistWithPopularStocks()
        }
    }
    
    // MARK: - Portfolio Management
    
    func addPortfolio(symbol: String, name: String, quantity: Double, price: Double) {
        let portfolio = Portfolio(
            symbol: symbol,
            name: name,
            quantity: quantity,
            averagePrice: price,
            purchaseDate: Date()
        )
        portfolios.append(portfolio)
        savePortfolios()
    }
    
    func removePortfolio(at indexSet: IndexSet) {
        portfolios.remove(atOffsets: indexSet)
        savePortfolios()
    }
    
    func updatePortfolio(_ portfolio: Portfolio, quantity: Double, price: Double) {
        if let index = portfolios.firstIndex(where: { $0.id == portfolio.id }) {
            portfolios[index] = Portfolio(
                symbol: portfolio.symbol,
                name: portfolio.name,
                quantity: quantity,
                averagePrice: price,
                purchaseDate: portfolio.purchaseDate
            )
            savePortfolios()
        }
    }
    
    // MARK: - Watchlist Management
    
    func addToWatchlist(symbol: String, name: String) {
        // 중복 확인
        guard !watchlist.contains(where: { $0.symbol == symbol }) else { return }
        guard watchlist.count < 500 else { return } // 최대 500개 제한
        
        let nextOrder = (watchlist.map { $0.sortOrder }.max() ?? 0) + 1
        let item = WatchlistItem(symbol: symbol, name: name, sortOrder: nextOrder)
        watchlist.append(item)
        saveWatchlist()
    }
    
    func removeFromWatchlist(at indexSet: IndexSet) {
        watchlist.remove(atOffsets: indexSet)
        reorderWatchlist()
        saveWatchlist()
    }
    
    func moveWatchlistItem(from source: IndexSet, to destination: Int) {
        watchlist.move(fromOffsets: source, toOffset: destination)
        reorderWatchlist()
        saveWatchlist()
    }
    
    private func reorderWatchlist() {
        for (index, _) in watchlist.enumerated() {
            watchlist[index].sortOrder = index
        }
    }
    
    private func initializeWatchlistWithPopularStocks() {
        for (index, (symbol, name)) in popularStocks.enumerated() {
            let item = WatchlistItem(symbol: symbol, name: name, sortOrder: index)
            watchlist.append(item)
        }
        saveWatchlist()
    }
    
    // MARK: - Data Persistence
    
    private func savePortfolios() {
        if let data = try? JSONEncoder().encode(portfolios) {
            UserDefaults.standard.set(data, forKey: portfolioKey)
        }
    }
    
    private func loadPortfolios() {
        guard let data = UserDefaults.standard.data(forKey: portfolioKey),
              let portfolios = try? JSONDecoder().decode([Portfolio].self, from: data) else {
            return
        }
        self.portfolios = portfolios
    }
    
    private func saveWatchlist() {
        if let data = try? JSONEncoder().encode(watchlist) {
            UserDefaults.standard.set(data, forKey: watchlistKey)
        }
    }
    
    private func loadWatchlist() {
        guard let data = UserDefaults.standard.data(forKey: watchlistKey),
              let watchlist = try? JSONDecoder().decode([WatchlistItem].self, from: data) else {
            return
        }
        self.watchlist = watchlist.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    // MARK: - Utility Methods
    
    func getPortfolioStockSymbols() -> [String] {
        return portfolios.map { $0.symbol }
    }
    
    func getWatchlistStockSymbols() -> [String] {
        return watchlist.map { $0.symbol }
    }
    
    func getAllUniqueSymbols() -> [String] {
        let portfolioSymbols = Set(getPortfolioStockSymbols())
        let watchlistSymbols = Set(getWatchlistStockSymbols())
        return Array(portfolioSymbols.union(watchlistSymbols))
    }
}
