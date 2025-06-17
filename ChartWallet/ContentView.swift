//
//  ContentView.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var stockManager = StockDataManager()
    @State private var selectedStock: StockItem?
    
    var body: some View {
        UpdatedMainTabView()
    }
}

//#Preview {
//    ContentView()
//}
