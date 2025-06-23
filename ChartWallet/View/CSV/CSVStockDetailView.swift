//
//  CSVStockDetailView.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUI

// MARK: - CSV 주식 상세 뷰
struct CSVStockDetailView: View {
    let stock: ExcelStockData
    @ObservedObject var portfolioManager: PortfolioManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 기본 정보
                    VStack(spacing: 12) {
                        Text(stock.companyName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 20) {
                            if let sector = stock.sector {
                                VStack {
                                    Text("섹터")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(sector)
                                        .font(.callout)
                                        .fontWeight(.medium)
                                }
                            }
                            
                            if let industry = stock.industry {
                                VStack {
                                    Text("산업")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(industry)
                                        .font(.callout)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
                    
                    // 가격 정보
                    VStack(spacing: 16) {
                        Text("가격 정보")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            if let usdPrice = stock.currentPriceUSD {
                                HStack {
                                    Text("현재가 (USD)")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("$\(usdPrice, specifier: "%.2f")")
                                        .fontWeight(.semibold)
                                }
                            }
                            
                            if let krwPrice = stock.currentPriceKRW {
                                HStack {
                                    Text("현재가 (KRW)")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("₩\(krwPrice, specifier: "%.0f")")
                                        .fontWeight(.semibold)
                                }
                            }
                            
                            if let week52High = stock.week52High {
                                HStack {
                                    Text("52주 최고가")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("$\(week52High, specifier: "%.2f")")
                                        .fontWeight(.medium)
                                }
                            }
                            
                            if let week52Low = stock.week52Low {
                                HStack {
                                    Text("52주 최저가")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("$\(week52Low, specifier: "%.2f")")
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
                    
                    // 애널리스트 정보
                    VStack(spacing: 16) {
                        Text("애널리스트 분석")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            if let rating = stock.analystRating {
                                // 원 단위 목표가로 표시
                                if let krwValue = Double(rating.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "원", with: "")) {
                                    HStack {
                                        Text("목표가 (KRW)")
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("₩\(krwValue, specifier: "%.0f")")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            
                            if let targetPrice = stock.analystTargetPrice {
                                HStack {
                                    Text("평가")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(evaluateRating(targetPrice))
                                        .fontWeight(.semibold)
                                        .foregroundColor(ratingColorFromValue(targetPrice))
                                }
                            }
                            
                            if let expectedReturn = stock.expectedReturn {
                                HStack {
                                    Text("예상 수익률")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(expectedReturn, specifier: "%.1f")%")
                                        .fontWeight(.semibold)
                                        .foregroundColor(expectedReturn >= 0 ? .green : .red)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
                    
                    // 업로드 정보
                    VStack(spacing: 8) {
                        Text("데이터 정보")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Text("업로드 일시")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(formatFullDate(stock.uploadDate))
                                .fontWeight(.medium)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
                    
                    // 액션 버튼
                    Button("관심목록에 추가") {
                        addToWatchlist()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .fontWeight(.semibold)
                }
                .padding()
            }
            .navigationTitle("상세 정보")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("닫기") { dismiss() })
        }
        .alert("알림", isPresented: $showingAlert) {
            Button("확인") { }
        } message: {
            Text(alertMessage)
        }
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
    
    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func addToWatchlist() {
        // 간단한 심볼 생성 (실제로는 더 정교한 로직 필요)
        let symbol = extractSymbol(from: stock.companyName)
        
        // 중복 확인
        if portfolioManager.watchlist.contains(where: { $0.symbol == symbol }) {
            alertMessage = "\(symbol)은(는) 이미 관심목록에 있습니다."
        } else {
            portfolioManager.addToWatchlist(symbol: symbol, name: stock.companyName)
            alertMessage = "\(symbol)이(가) 관심목록에 추가되었습니다."
        }
        
        showingAlert = true
    }
    
    private func extractSymbol(from companyName: String) -> String {
        // 회사명에서 심볼 추출 (간단한 버전)
        let cleanName = companyName.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "Inc.", with: "")
            .replacingOccurrences(of: "Corp.", with: "")
            .replacingOccurrences(of: "주식회사", with: "")
            .replacingOccurrences(of: "전자", with: "")
        
        return String(cleanName.prefix(4)).uppercased()
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

#Preview {
//    CSVDataView(
//        excelManager: ExcelImportManager(),
//        portfolioManager: PortfolioManager(),
//        stockManager: StockDataManager()
//    )
}
