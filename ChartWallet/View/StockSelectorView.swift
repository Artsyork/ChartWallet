//
//  StockSelectorView.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUICore
import SwiftUI

struct StockSelectorView: View {
    @Binding var selectedSymbol: String
    @Binding var customSymbol: String
    let popularSymbols: [String]
    let onSymbolSelected: (String) -> Void
    
    var body: some View {
        VStack {
            // 인기 종목 버튼들
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                ForEach(popularSymbols, id: \.self) { symbol in
                    Button(action: {
                        onSymbolSelected(symbol)
                    }) {
                        Text(symbol)
                            .font(.caption)
                            .foregroundColor(selectedSymbol == symbol ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedSymbol == symbol ? Color.blue : Color.gray.opacity(0.2))
                            )
                    }
                }
            }
            
            // 커스텀 종목 입력
            HStack {
                TextField("종목 코드 입력 (예: NVDA)", text: $customSymbol)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.allCharacters)
                
                Button("추가") {
                    if !customSymbol.isEmpty {
                        onSymbolSelected(customSymbol.uppercased())
                        customSymbol = ""
                    }
                }
                .disabled(customSymbol.isEmpty)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(customSymbol.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
}
