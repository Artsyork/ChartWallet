//
//  EnhancedStatusView.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import SwiftUICore
import Network

struct EnhancedStatusView: View {
    let connectionStatus: FinnhubWebSocketManager.ConnectionStatus
    let isNetworkConnected: Bool
    let connectionType: NWInterface.InterfaceType?
    
    var body: some View {
        VStack(spacing: 8) {
            // WebSocket 연결 상태
            HStack {
                Circle()
                    .fill(websocketStatusColor)
                    .frame(width: 10, height: 10)
                
                Text("WebSocket: \(websocketStatusText)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 네트워크 상태
            HStack {
                Circle()
                    .fill(isNetworkConnected ? .green : .red)
                    .frame(width: 10, height: 10)
                
                Text("네트워크: \(networkStatusText)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
    
    private var websocketStatusColor: Color {
        switch connectionStatus {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .red
        }
    }
    
    private var websocketStatusText: String {
        switch connectionStatus {
        case .connected: return "연결됨"
        case .connecting: return "연결 중..."
        case .disconnected: return "연결 끊김"
        }
    }
    
    private var networkStatusText: String {
        if !isNetworkConnected {
            return "연결 없음"
        }
        
        switch connectionType {
        case .wifi: return "Wi-Fi 연결됨"
        case .cellular: return "셀룰러 연결됨"
        default: return "연결됨"
        }
    }
}
