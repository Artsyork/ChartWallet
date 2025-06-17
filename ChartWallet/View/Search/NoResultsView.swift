//
//  NoResultsView.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

struct NoResultsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("검색 결과가 없습니다")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("다른 검색어를 시도해보세요")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
