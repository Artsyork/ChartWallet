//
//  AnalystRecommendationView.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUICore

struct AnalystRecommendationView: View {
    let recommendation: AnalystRecommendation
    let currentPrice: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("애널리스트 평가")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("평균 추천등급")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(recommendation.averageRating.rawValue)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(recommendation.averageRating.color)
                }
                
                Spacer()
                
                if let targetPrice = recommendation.analystTargetPrice {
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("목표가")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("$\(targetPrice, specifier: "%.2f")")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }
            
            if let targetPrice = recommendation.analystTargetPrice,
               currentPrice > 0 {
                let upside = ((targetPrice - currentPrice) / currentPrice) * 100
                
                HStack {
                    Text("예상 수익률:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(upside, specifier: "%.1f")%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(upside >= 0 ? .green : .red)
                }
                .padding(.top, 8)
            }
            
            // 목표가 범위
            if let high = recommendation.analystTargetPriceHigh,
               let low = recommendation.analystTargetPriceLow {
                VStack(alignment: .leading, spacing: 8) {
                    Text("목표가 범위")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("최고: $\(high, specifier: "%.2f")")
                        Spacer()
                        Text("최저: $\(low, specifier: "%.2f")")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
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
