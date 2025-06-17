//
//  SearchBarPlaceholder.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUICore

// MARK: - Search Bar Placeholder
struct SearchBarPlaceholder: View {
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                Text("종목명 또는 심볼 검색 (예: Apple, AAPL)")
                    .foregroundColor(.secondary)
                    .font(.body)
                
                Spacer()
                
                Image(systemName: "arrow.up.right.square")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
