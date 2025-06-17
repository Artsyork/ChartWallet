//
//  FeatureRow.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUICore

// MARK: - 헬퍼 뷰 컴포넌트들
struct FeatureRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(text)
                .font(.caption)
        }
    }
}
