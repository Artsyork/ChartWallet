//
//  EmptyCSVDataView.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUI

// MARK: - 빈 상태 뷰
struct EmptyCSVDataView: View {
    let onImport: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "doc.text.below.ecg")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("CSV 데이터가 없습니다")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Excel 또는 CSV 파일을 업로드하여\n주식 데이터를 가져와보세요")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("파일 가져오기", action: onImport)
                .buttonStyle(.borderedProminent)
                .font(.headline)
            
            Spacer()
        }
        .padding()
    }
}
