//
//  AddPortfolioView.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

struct AddPortfolioView: View {
    @ObservedObject var portfolioManager: PortfolioManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var stockSymbol = ""
    @State private var companyName = ""
    @State private var quantity = ""
    @State private var purchasePrice = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // 포커스 상태 관리
    @FocusState private var focusedField: Field?
    
    enum Field {
        case symbol, name, quantity, price
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 안내 텍스트
                VStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    
                    Text("새 종목 추가")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("구매한 주식의 정보를 입력해주세요")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // 입력 폼
                VStack(spacing: 16) {
                    // 종목 코드
                    VStack(alignment: .leading, spacing: 8) {
                        Text("종목 코드")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextField("예: AAPL, GOOGL", text: $stockSymbol)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.allCharacters)
                            .focused($focusedField, equals: .symbol)
                            .onSubmit {
                                focusedField = .name
                            }
                    }
                    
                    // 회사명
                    VStack(alignment: .leading, spacing: 8) {
                        Text("회사명")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextField("예: Apple Inc.", text: $companyName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($focusedField, equals: .name)
                            .onSubmit {
                                focusedField = .quantity
                            }
                    }
                    
                    // 보유 수량
                    VStack(alignment: .leading, spacing: 8) {
                        Text("보유 수량")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            TextField("예: 10.5", text: $quantity)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .quantity)
                                .onSubmit {
                                    focusedField = .price
                                }
                            
                            Text("주")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("소수점을 포함한 수량 입력 가능")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    // 매수 단가
                    VStack(alignment: .leading, spacing: 8) {
                        Text("매수 단가")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text("$")
                                .font(.callout)
                                .foregroundColor(.secondary)
                            
                            TextField("예: 150.25", text: $purchasePrice)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .price)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
                
                // 투자 금액 계산 표시
                if let qty = Double(quantity), let price = Double(purchasePrice), qty > 0, price > 0 {
                    VStack(spacing: 8) {
                        Text("투자 금액")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("$\(qty * price, specifier: "%.2f")")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.1))
                    )
                }
                
                Spacer()
                
                // 추가 버튼
                Button("포트폴리오에 추가") {
                    addPortfolio()
                }
                .disabled(!isFormValid)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    isFormValid ? Color.green : Color.gray.opacity(0.3)
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .fontWeight(.semibold)
            }
            .padding()
            .navigationTitle("종목 추가")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("취소") {
                    dismiss()
                }
            )
            .alert("알림", isPresented: $showingAlert) {
                Button("확인") {
                    if alertMessage.contains("추가되었습니다") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .onTapGesture {
                // 빈 공간 탭 시 키보드 숨기기
                focusedField = nil
            }
        }
    }
    
    private var isFormValid: Bool {
        !stockSymbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !companyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(quantity) != nil &&
        Double(quantity) ?? 0 > 0 &&
        Double(purchasePrice) != nil &&
        Double(purchasePrice) ?? 0 > 0
    }
    
    private func addPortfolio() {
        let symbol = stockSymbol.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let name = companyName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let qty = Double(quantity), qty > 0 else {
            alertMessage = "올바른 수량을 입력해주세요."
            showingAlert = true
            return
        }
        
        guard let price = Double(purchasePrice), price > 0 else {
            alertMessage = "올바른 매수 단가를 입력해주세요."
            showingAlert = true
            return
        }
        
        // 중복 확인
        if portfolioManager.portfolios.contains(where: { $0.symbol == symbol }) {
            alertMessage = "\(symbol)은(는) 이미 포트폴리오에 있습니다. 기존 항목을 수정해주세요."
            showingAlert = true
            return
        }
        
        // 포트폴리오에 추가
        portfolioManager.addPortfolio(symbol: symbol, name: name, quantity: qty, price: price)
        
        alertMessage = "\(symbol)이(가) 포트폴리오에 추가되었습니다."
        showingAlert = true
    }
}

#Preview {
    AddPortfolioView(portfolioManager: PortfolioManager())
}
