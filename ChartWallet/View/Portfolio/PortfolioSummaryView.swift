//
//  PortfolioSummaryView.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUICore

import SwiftUI

struct PortfolioSummaryView: View {
    let portfolios: [Portfolio]
    let stocks: [StockItem]
    
    private var totalInvestment: Double {
        portfolios.reduce(0) { $0 + $1.totalInvestment }
    }
    
    private var currentValue: Double {
        portfolios.reduce(0) { total, portfolio in
            if let stock = stocks.first(where: { $0.symbol == portfolio.symbol }) {
                return total + portfolio.currentValue(currentPrice: stock.currentPrice)
            }
            return total + portfolio.totalInvestment // 현재가가 없으면 매수가로 계산
        }
    }
    
    private var totalProfitLoss: Double {
        currentValue - totalInvestment
    }
    
    private var totalProfitLossPercent: Double {
        guard totalInvestment > 0 else { return 0 }
        return (totalProfitLoss / totalInvestment) * 100
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 총 자산 현황
            VStack(spacing: 8) {
                Text("총 자산")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("$\(currentValue, specifier: "%.2f")")
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack(spacing: 4) {
                    Image(systemName: totalProfitLoss >= 0 ? "arrow.up" : "arrow.down")
                        .font(.caption)
                    
                    Text("$\(abs(totalProfitLoss), specifier: "%.2f") (\(abs(totalProfitLossPercent), specifier: "%.2f")%)")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(totalProfitLoss >= 0 ? .green : .red)
            }
            
            // 상세 정보
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("투자 원금")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("$\(totalInvestment, specifier: "%.2f")")
                        .font(.callout)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("보유 종목")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(portfolios.count)개")
                        .font(.callout)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}
