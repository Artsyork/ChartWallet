//
//  FileFormatHelpView.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUI

struct FileFormatHelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("파일 형식 문제 해결 가이드")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // CSV 변환 방법
                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. Excel → CSV 변환")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• Excel에서 파일 열기")
                            Text("• '파일' → '다른 이름으로 저장'")
                            Text("• 형식: 'CSV(쉼표로 구분)(*.csv)'")
                            Text("• 저장 후 CSV 파일 사용")
                        }
                        .font(.caption)
                    }
                    
                    // 인코딩 문제
                    VStack(alignment: .leading, spacing: 12) {
                        Text("2. 한글 깨짐 문제")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• 메모장에서 CSV 파일 열기")
                            Text("• '다른 이름으로 저장'")
                            Text("• 인코딩: UTF-8 선택")
                            Text("• 저장 후 다시 시도")
                        }
                        .font(.caption)
                    }
                    
                    // 데이터 형식
                    VStack(alignment: .leading, spacing: 12) {
                        Text("3. 데이터 형식 확인")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• 첫 번째 행: 헤더 필수")
                            Text("• 두 번째 행부터: 실제 데이터")
                            Text("• 쉼표로 열 구분")
                            Text("• 회사명은 반드시 포함")
                        }
                        .font(.caption)
                    }
                }
                .padding()
            }
            .navigationTitle("도움말")
            .navigationBarItems(
                trailing: Button("닫기") { dismiss() }
            )
        }
    }
}
