//
//  SearchExampleRow.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

struct SearchExampleRow: View {
    let symbol: String
    let description: String
    
    var body: some View {
        HStack {
            Text(symbol)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.blue)
                .frame(width: 60, alignment: .leading)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
}
