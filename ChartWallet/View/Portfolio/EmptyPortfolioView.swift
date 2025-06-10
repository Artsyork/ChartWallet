//
//  EmptyPortfolioView.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUICore
import SwiftUI

// MARK: - Empty Portfolio View
struct EmptyPortfolioView: View {
    let onAddStock: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "wallet.pass")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("보유 종목이 없습니다")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("첫 번째 종목을 추가해보세요")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Button("내 종목 추가하기", action: onAddStock)
                .buttonStyle(.borderedProminent)
                .font(.headline)
            
            Spacer()
        }
    }
}
