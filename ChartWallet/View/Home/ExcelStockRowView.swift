//
//  ExcelStockRowView.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUI

struct ExcelStockRowView: View {
    let stock: ExcelStockData
    
    var body: some View {
        HStack(spacing: 12) {
            // 순번
            Text("\(stock.seq)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 30)
            
            // 회사명
            VStack(alignment: .leading, spacing: 2) {
                Text(stock.companyName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if let sector = stock.sector {
                    Text(sector)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // 현재가
            VStack(alignment: .trailing, spacing: 2) {
                Text(stock.formattedCurrentPrice)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if let rating = stock.analystRating {
                    Text(rating)
                        .font(.caption2)
                        .foregroundColor(ratingColor(rating))
                }
            }
            
            // 예상 수익률
            if let expectedReturn = stock.expectedReturn {
                Text("\(expectedReturn, specifier: "%.1f")%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(expectedReturn >= 0 ? .green : .red)
                    .frame(width: 50, alignment: .trailing)
            } else {
                Text("--")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .trailing)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5).opacity(0.5))
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
