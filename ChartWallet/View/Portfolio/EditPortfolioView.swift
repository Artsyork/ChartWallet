//
//  EditPortfolioView.swift
//  ChartWallet
//
//  Created by DY on 6/10/25.
//

import SwiftUI

struct EditPortfolioView: View {
    let portfolio: Portfolio
    @ObservedObject var portfolioManager: PortfolioManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var quantity: String
    @State private var purchasePrice: String
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingDeleteAlert = false
    
    // 포커스 상태 관리
    @FocusState private var focusedField: Field?
    
    enum Field {
        case quantity, price
    }
    
    init(portfolio: Portfolio, portfolioManager: PortfolioManager) {
        self.portfolio = portfolio
        self.portfolioManager = portfolioManager
        self._quantity = State(initialValue: String(portfolio.quantity))
        self._purchasePrice = State(initialValue: String(portfolio.averagePrice))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 종목 정보 (수정 불가)
                VStack(spacing: 12) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 4) {
                        Text(portfolio.symbol)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(portfolio.name)
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("매수일: \(portfolio.purchaseDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
                
                // 수정 가능한 필드들
                VStack(spacing: 16) {
                    // 보유 수량
                    VStack(alignment: .leading, spacing: 8) {
                        Text("보유 수량")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            TextField("수량", text: $quantity)
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
                        
                        Text("현재: \(portfolio.quantity, specifier: "%.3f")주")
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
                            
                            TextField("단가", text: $purchasePrice)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .price)
                        }
                        
                        Text("현재: $\(portfolio.averagePrice, specifier: "%.2f")")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
                
                // 변경된 투자 금액 표시
                if let qty = Double(quantity), let price = Double(purchasePrice), qty > 0, price > 0 {
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("기존 투자금액")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("$\(portfolio.totalInvestment, specifier: "%.2f")")
                                    .font(.callout)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("새 투자금액")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("$\(qty * price, specifier: "%.2f")")
                                    .font(.callout)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                
                Spacer()
                
                // 버튼들
                VStack(spacing: 12) {
                    // 수정 버튼
                    Button("변경사항 저장") {
                        updatePortfolio()
                    }
                    .disabled(!isFormValid || !hasChanges)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        (isFormValid && hasChanges) ? Color.blue : Color.gray.opacity(0.3)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .fontWeight(.semibold)
                    
                    // 삭제 버튼
                    Button("포트폴리오에서 제거") {
                        showingDeleteAlert = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .fontWeight(.semibold)
                }
            }
            .padding()
            .navigationTitle("포트폴리오 편집")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("취소") {
                    dismiss()
                }
            )
            .alert("알림", isPresented: $showingAlert) {
                Button("확인") {
                    if alertMessage.contains("저장되었습니다") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .alert("포트폴리오 제거", isPresented: $showingDeleteAlert) {
                Button("취소", role: .cancel) { }
                Button("제거", role: .destructive) {
                    deletePortfolio()
                }
            } message: {
                Text("\(portfolio.symbol)을(를) 포트폴리오에서 제거하시겠습니까?")
            }
            .onTapGesture {
                focusedField = nil
            }
        }
    }
    
    private var isFormValid: Bool {
        guard let qty = Double(quantity), qty > 0,
              let price = Double(purchasePrice), price > 0 else {
            return false
        }
        return true
    }
    
    private var hasChanges: Bool {
        let currentQty = Double(quantity) ?? 0
        let currentPrice = Double(purchasePrice) ?? 0
        
        return currentQty != portfolio.quantity || currentPrice != portfolio.averagePrice
    }
    
    private func updatePortfolio() {
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
        
        portfolioManager.updatePortfolio(portfolio, quantity: qty, price: price)
        
        alertMessage = "변경사항이 저장되었습니다."
        showingAlert = true
    }
    
    private func deletePortfolio() {
        if let index = portfolioManager.portfolios.firstIndex(where: { $0.id == portfolio.id }) {
            portfolioManager.removePortfolio(at: IndexSet(integer: index))
            dismiss()
        }
    }
}

#Preview {
    EditPortfolioView(
        portfolio: Portfolio(
            symbol: "AAPL",
            name: "Apple Inc.",
            quantity: 10.5,
            averagePrice: 150.00,
            purchaseDate: Date()
        ),
        portfolioManager: PortfolioManager()
    )
}
