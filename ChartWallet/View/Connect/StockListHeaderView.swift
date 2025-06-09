//
//  StockListHeaderView.swift
//  ChartWallet
//
//  Created by DY on 6/9/25.
//

import SwiftUICore

struct StockListHeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            // 종목명
            Text("종목")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            // 애널리스트 평가
            Text("평가")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 50)
            
            // 목표가
            Text("목표가")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 45)
            
            // 예상 수익률
            Text("수익률")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 45)
            
            Spacer()
            
            // 현재주가
            Text("현재가")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .trailing)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            Rectangle()
                .fill(Color(.systemGray5))
        )
    }
}
