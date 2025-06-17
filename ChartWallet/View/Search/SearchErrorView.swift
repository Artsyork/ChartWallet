//
//  SearchErrorView.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

struct SearchErrorView: View {
    let error: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("검색 오류")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(error)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("다시 시도") {
                onRetry()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
