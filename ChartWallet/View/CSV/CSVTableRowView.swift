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
        HStack(spacing: 8) {
            // 종목명
            VStack(alignment: .leading, spacing: 2) {
                Text(stock.companyName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                if let sector = stock.sector {
                    Text(sector)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Text(formatUploadDate(stock.uploadDate))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 80, alignment: .leading)
            
            // 현재가/목표가
            VStack(alignment: .trailing, spacing: 2) {
                Text(stock.formattedCurrentPrice)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(stock.formattedTargetPrice)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(width: 60, alignment: .trailing)
            
            // 애널리스트 평가
            VStack {
                if let rating = stock.analystRating {
                    // 목표가 값을 평가로 표시 (수치에 따른 평가)
                    
                    Text(rating)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(stock.formatBuyComment.color)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                } else {
                    Text("--")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 50, alignment: .center)
            
            // 예상 수익률
            VStack(alignment: .trailing) {
                if let expectedReturn = stock.expectedReturn {
                    Text("\(expectedReturn, specifier: "%.2f")%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(expectedReturn >= 0 ? .green : .red)
                } else {
                    Text("--")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 50, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.clear)
        .contentShape(Rectangle())
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
    
    private func formatUploadDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    // 수치값을 기반으로 평가 문자열 생성
    private func evaluateRating(_ value: Double) -> String {
        switch value {
        case 0...20: return "매도"
        case 21...40: return "보유"
        case 41...60: return "중립"
        case 61...80: return "매수"
        case 81...100: return "적극매수"
        default: return "평가없음"
        }
    }
    
    // 수치값을 기반으로 색상 결정
    private func ratingColorFromValue(_ value: Double) -> Color {
        switch value {
        case 0...20: return .red
        case 21...40: return .orange
        case 41...60: return .yellow
        case 61...80: return .mint
        case 81...100: return .green
        default: return .secondary
        }
    }
}
