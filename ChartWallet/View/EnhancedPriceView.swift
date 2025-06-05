//
//  EnhancedPriceView.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUICore

struct EnhancedPriceView: View {
    let symbol: String
    let price: Double
    let change: Double
    let changePercent: Double
    let dayHigh: Double
    let dayLow: Double
    
    var body: some View {
        VStack(spacing: 12) {
            Text(symbol)
                .font(.title2)
                .fontWeight(.bold)
            
            Text("$\(price, specifier: "%.2f")")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            if change != 0 {
                HStack {
                    Image(systemName: change > 0 ? "arrow.up" : "arrow.down")
                    Text("$\(abs(change), specifier: "%.2f") (\(abs(changePercent), specifier: "%.2f")%)")
                }
                .foregroundColor(change > 0 ? .green : .red)
                .font(.callout)
                .fontWeight(.medium)
            }
            
            if dayHigh > 0 && dayLow > 0 {
                HStack(spacing: 20) {
                    VStack {
                        Text("일일 최고")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(dayHigh, specifier: "%.2f")")
                            .font(.callout)
                            .fontWeight(.semibold)
                    }
                    
                    VStack {
                        Text("일일 최저")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(dayLow, specifier: "%.2f")")
                            .font(.callout)
                            .fontWeight(.semibold)
                    }
                }
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
