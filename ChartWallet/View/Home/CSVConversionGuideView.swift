
//
//  CSVConversionGuideView.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import SwiftUI

// MARK: - CSV 변환 가이드 뷰
struct CSVConversionGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Excel → CSV 변환
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.green)
                                .font(.title2)
                            Text("Excel → CSV 변환 방법")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📊 Microsoft Excel에서:")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("1. Excel에서 파일 열기")
                                Text("2. '파일' → '다른 이름으로 저장' 클릭")
                                Text("3. 파일 형식에서 'CSV(쉼표로 구분)(*.csv)' 선택")
                                Text("4. 인코딩: 'UTF-8' 선택 (한글 깨짐 방지)")
                                Text("5. 저장 후 CSV 파일을 앱에 업로드")
                            }
                            .font(.callout)
                            .padding(.leading)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Google Sheets → CSV 변환
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("Google Sheets → CSV")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("🌐 Google Sheets에서:")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("1. Google Sheets에서 파일 열기")
                                Text("2. '파일' → '다운로드' 클릭")
                                Text("3. 'CSV(.csv)' 선택")
                                Text("4. 다운로드된 CSV 파일을 앱에 업로드")
                            }
                            .font(.callout)
                            .padding(.leading)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    // 한글 깨짐 해결
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "textformat.abc")
                                .foregroundColor(.orange)
                                .font(.title2)
                            Text("한글 깨짐 해결 방법")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("🇰🇷 한글이 깨진다면:")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("1. 메모장(Windows) 또는 텍스트편집기(Mac)에서 CSV 파일 열기")
                                Text("2. '다른 이름으로 저장' 선택")
                                Text("3. 인코딩을 'UTF-8'로 변경")
                                Text("4. 저장 후 다시 앱에 업로드")
                            }
                            .font(.callout)
                            .padding(.leading)
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    
                    // 데이터 형식 예시
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "table")
                                .foregroundColor(.purple)
                                .font(.title2)
                            Text("올바른 데이터 형식")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📋 CSV 파일 예시:")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("""
SEQ,회사명,현재가,섹터,산업,애널리스트평가,목표가,예상수익률
1,삼성전자,72000,기술,반도체,매수,80000,11.1%
2,SK하이닉스,135000,기술,메모리,적극매수,160000,18.5%
3,LG에너지솔루션,485000,에너지,배터리,매수,550000,13.4%
""")
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("CSV 변환 가이드")
            .navigationBarItems(trailing: Button("닫기") { dismiss() })
        }
    }
}
