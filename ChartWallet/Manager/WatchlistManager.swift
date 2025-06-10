//
//  WatchlistManager.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import Foundation

// MARK: - Watchlist Manager
class WatchlistManager: ObservableObject {
    @Published var watchlistSymbols: [String] = []
    private let watchlistKey = "WatchlistSymbols"
    
    init() {
        loadWatchlist()
    }
    
    func addToWatchlist(_ symbol: String) {
        if !watchlistSymbols.contains(symbol) && watchlistSymbols.count < 500 {
            watchlistSymbols.append(symbol)
            saveWatchlist()
        }
    }
    
    func removeFromWatchlist(_ symbol: String) {
        watchlistSymbols.removeAll { $0 == symbol }
        saveWatchlist()
    }
    
    func isInWatchlist(_ symbol: String) -> Bool {
        return watchlistSymbols.contains(symbol)
    }
    
    func moveStock(from source: IndexSet, to destination: Int) {
        watchlistSymbols.move(fromOffsets: source, toOffset: destination)
        saveWatchlist()
    }
    
    private func saveWatchlist() {
        UserDefaults.standard.set(watchlistSymbols, forKey: watchlistKey)
    }
    
    private func loadWatchlist() {
        watchlistSymbols = UserDefaults.standard.array(forKey: watchlistKey) as? [String] ?? []
    }
}
