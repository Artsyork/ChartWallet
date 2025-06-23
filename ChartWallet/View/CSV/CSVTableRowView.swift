//
//  CSVTableRowView.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUI

// MARK: - CSV 테이블 행
struct CSVTableRowView: View {
    let stock: ExcelStockData
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 8) {
                // 종목명
                VStack(alignment: .leading, spacing: 2) {
                    Text(stock.companyName)
                        .font(.callout)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    if let sector = stock.sector {
                        Text(sector + " (" + formatUploadDate(stock.uploadDate) + ")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .frame(width: geometry.size.width * 0.4, alignment: .leading)
                
                // 현재가/목표가
                VStack(alignment: .trailing, spacing: 2) {
                    Text(stock.formattedCurrentPrice)
                        .font(.callout)
                        .fontWeight(.medium)
                    
                    Text(stock.formattedTargetPrice)
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(stock.formatBuyComment.color)
                }
                .frame(width: geometry.size.width * 0.3, alignment: .trailing)
                
                // 애널리스트 평가
                VStack {
                    if let rating = stock.analystRating {
                        // 목표가 값을 평가로 표시 (수치에 따른 평가)
                        
                        Text(rating)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(stock.formatBuyComment.color)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                    } else {
                        Text("--")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: geometry.size.width * 0.1, alignment: .center)
                
                // 예상 수익률
                VStack(alignment: .trailing) {
                    if let expectedReturn = stock.expectedReturn {
                        Text("\(expectedReturn, specifier: "%.2f")%")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(expectedReturn >= 0 ? .green : .red)
                    } else {
                        Text("--")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: geometry.size.width * 0.2, alignment: .leading)
            }
        }
        .frame(height: 40)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.clear)
        .contentShape(Rectangle())
    }
    
    private func formatUploadDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

}
