//
//  SearchBar.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    let onSearchButtonClicked: () -> Void
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("종목명 또는 심볼 검색 (예: Apple, AAPL)", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit {
                        onSearchButtonClicked()
                    }
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
        }
    }
}
