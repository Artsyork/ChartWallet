//
//  CSVTableHeaderView.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUI

// MARK: - CSV 테이블 헤더
struct CSVTableHeaderView: View {
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 8) {
                Text("종목명")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(width: geometry.size.width * 0.4, alignment: .leading)
                
                Text("현재가/목표가")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(width: geometry.size.width * 0.3, alignment: .trailing)
                
                Text("평가")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(width: geometry.size.width * 0.1, alignment: .center)
                
                Text("수익률")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(width: geometry.size.width * 0.2, alignment: .leading)
            }
        }
        .frame(height: 16)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemGray5))
    }
}
