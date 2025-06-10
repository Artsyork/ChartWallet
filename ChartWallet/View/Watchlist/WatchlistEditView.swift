//
//  WatchlistEditView.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

struct WatchlistEditView: View {
    @ObservedObject var portfolioManager: PortfolioManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var newSymbol = ""
    @State private var newCompanyName = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 새 종목 추가 섹션
                VStack(alignment: .leading, spacing: 12) {
                    Text("새 종목 추가")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        TextField("종목 코드 (예: NVDA)", text: $newSymbol)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.allCharacters)
                        
                        TextField("회사명 (예: NVIDIA Corp.)", text: $newCompanyName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("관심목록에 추가") {
                            addToWatchlist()
                        }
                        .disabled(newSymbol.isEmpty || newCompanyName.isEmpty)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            (newSymbol.isEmpty || newCompanyName.isEmpty) ?
                                Color.gray.opacity(0.3) : Color.blue
                        )
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                // 현재 관심목록
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("현재 관심목록 (\(portfolioManager.watchlist.count)/500)")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    if portfolioManager.watchlist.isEmpty {
                        Text("관심목록이 비어있습니다")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        List {
                            ForEach(portfolioManager.watchlist.sorted { $0.sortOrder < $1.sortOrder }) { item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.symbol)
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        
                                        Text(item.name)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("순서: \(item.sortOrder + 1)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            .onDelete(perform: portfolioManager.removeFromWatchlist)
                            .onMove(perform: portfolioManager.moveWatchlistItem)
                        }
                        .environment(\.editMode, .constant(.active))
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("관심목록 편집")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("완료") {
                    dismiss()
                }
            )
            .alert("알림", isPresented: $showingAlert) {
                Button("확인") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func addToWatchlist() {
        let symbol = newSymbol.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let name = newCompanyName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 유효성 검사
        guard !symbol.isEmpty && !name.isEmpty else {
            alertMessage = "종목 코드와 회사명을 모두 입력해주세요."
            showingAlert = true
            return
        }
        
        // 중복 확인
        if portfolioManager.watchlist.contains(where: { $0.symbol == symbol }) {
            alertMessage = "\(symbol)은(는) 이미 관심목록에 있습니다."
            showingAlert = true
            return
        }
        
        // 최대 개수 확인
        if portfolioManager.watchlist.count >= 500 {
            alertMessage = "관심목록은 최대 500개까지 추가할 수 있습니다."
            showingAlert = true
            return
        }
        
        // 관심목록에 추가
        portfolioManager.addToWatchlist(symbol: symbol, name: name)
        
        // 입력 필드 초기화
        newSymbol = ""
        newCompanyName = ""
        
        alertMessage = "\(symbol)이(가) 관심목록에 추가되었습니다."
        showingAlert = true
    }
}

#Preview {
    WatchlistEditView(portfolioManager: PortfolioManager())
}
