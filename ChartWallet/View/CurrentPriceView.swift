//
//  CurrentPriceView.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUICore

struct CurrentPriceView: View {
    let symbol: String
    let price: Double
    let change: Double
    
    var body: some View {
        VStack {
            Text(symbol)
                .font(.title2)
                .fontWeight(.bold)
            
            Text("$\(price, specifier: "%.2f")")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            if change != 0 {
                HStack {
                    Image(systemName: change > 0 ? "arrow.up" : "arrow.down")
                    Text("$\(abs(change), specifier: "%.2f")")
                }
                .foregroundColor(change > 0 ? .green : .red)
                .font(.caption)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
        .padding(.horizontal)
    }
}
