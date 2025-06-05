//
//  ConnectionStatusView.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUICore
import SwiftUI

struct ConnectionStatusView: View {
    let status: FinnhubWebSocketManager.ConnectionStatus
    
    var body: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
            
            Text(statusText)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if status == .connecting {
                ProgressView()
                    .scaleEffect(0.5)
            }
        }
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
}
