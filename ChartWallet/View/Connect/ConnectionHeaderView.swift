//
//  ConnectionHeaderView.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUICore
import SwiftUI

struct ConnectionHeaderView: View {
    let status: StockDataManager.ConnectionStatus
    let lastAnalystUpdate: Date?
    let nextAnalystUpdate: Date?
    let onConnect: () -> Void
    let onTestData: () -> Void
    let onForceUpdate: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // WebSocket 연결 상태
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                        
                        Text(statusText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("실시간 데이터 스트리밍")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    if status == .disconnected {
                        Button("연결") {
                            onConnect()
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                    
                    Button("🧪 테스트") {
                        onTestData()
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
            }
            
            // 애널리스트 데이터 상태
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .foregroundColor(.mint)
                        .font(.caption)
                    
                    Text("애널리스트 평가")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("수동 업데이트") {
                        onForceUpdate()
                    }
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.mint.opacity(0.2))
                    .foregroundColor(.mint)
                    .cornerRadius(4)
                }
                
                if let lastUpdate = lastAnalystUpdate {
                    Text("마지막 업데이트: \(formatRelativeTime(lastUpdate))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                if let nextUpdate = nextAnalystUpdate {
                    Text("다음 업데이트: \(formatRelativeTime(nextUpdate))")
                        .font(.caption2)
                        .foregroundColor(.mint)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var statusColor: Color {
        switch status {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .red
        }
    }
    
    private var statusText: String {
        switch status {
        case .connected: return "연결됨"
        case .connecting: return "연결 중..."
        case .disconnected: return "연결 끊김"
        }
    }
    
    private func formatRelativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
