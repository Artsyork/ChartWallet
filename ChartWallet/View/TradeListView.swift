//
//  TradeListView.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUICore
import SwiftUI

struct TradeListView: View {
    let trades: [StockTrade]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("최근 거래")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(trades.count)개 거래")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            if trades.isEmpty {
                Text("거래 데이터를 기다리는 중...")
                    .foregroundColor(.secondary)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                List(trades.reversed()) { trade in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("$\(trade.price, specifier: "%.2f")")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(trade.timestamp.formatted(date: .omitted, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            if let volume = trade.volume {
                                Text("Vol: \(volume)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(trade.symbol)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(PlainListStyle())
                .frame(maxHeight: 200)
            }
        }
    }
}
