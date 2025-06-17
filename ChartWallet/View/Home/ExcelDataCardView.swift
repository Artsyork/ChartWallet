//
//  ExcelDataCardView.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUI

struct ExcelDataCardView: View {
    let stock: ExcelStockData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 회사명
            Text(stock.companyName)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // 현재가
            if let usdPrice = stock.currentPriceUSD {
                Text("$\(usdPrice, specifier: "%.2f")")
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            } else if let krwPrice = stock.currentPriceKRW {
                Text("₩\(krwPrice, specifier: "%.0f")")
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            // 섹터
            if let sector = stock.sector {
                Text(sector)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 애널리스트 평가 및 수익률
            HStack {
                if let rating = stock.analystRating {
                    Text(rating)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(ratingColor(rating))
                        .lineLimit(1)
                }
                
                Spacer()
                
                if let expectedReturn = stock.expectedReturn {
                    Text("\(expectedReturn, specifier: "%.1f")%")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(expectedReturn >= 0 ? .green : .red)
                }
            }
        }
        .padding(12)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func ratingColor(_ rating: String) -> Color {
        switch rating.lowercased() {
        case let r where r.contains("strong buy"):
            return .green
        case let r where r.contains("buy"):
            return .mint
        case let r where r.contains("hold"):
            return .yellow
        case let r where r.contains("sell"):
            return .orange
        case let r where r.contains("strong sell"):
            return .red
        default:
            return .secondary
        }
    }
}
