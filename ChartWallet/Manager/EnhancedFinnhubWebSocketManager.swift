//
//  EnhancedFinnhubWebSocketManager.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import Foundation
import Combine
import UIKit

class EnhancedFinnhubWebSocketManager: FinnhubWebSocketManager {
    @Published var networkMonitor = NetworkMonitor()
    private var cancellables = Set<AnyCancellable>()
    private var reconnectTimer: Timer?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private var reconnectDelay: TimeInterval = 1.0
    
    override init() {
        super.init()
        setupNetworkMonitoring()
        setupAppStateObservers()
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.$isConnected
            .dropFirst() // 초기값 무시
            .sink { [weak self] isConnected in
                if isConnected {
                    self?.handleNetworkReconnected()
                } else {
                    self?.handleNetworkDisconnected()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupAppStateObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    @objc private func appWillEnterForeground() {
        print("앱이 포그라운드로 전환됨")
        if networkMonitor.isConnected && connectionStatus == .disconnected {
            reconnectWithDelay()
        }
    }
    
    @objc private func appDidEnterBackground() {
        print("앱이 백그라운드로 전환됨")
        disconnect()
        stopReconnectTimer()
    }
    
    private func handleNetworkReconnected() {
        print("네트워크 연결 복구됨")
        if connectionStatus == .disconnected {
            reconnectWithDelay()
        }
    }
    
    private func handleNetworkDisconnected() {
        print("네트워크 연결 끊김")
        disconnect()
        stopReconnectTimer()
    }
    
    private func reconnectWithDelay() {
        guard reconnectAttempts < maxReconnectAttempts else {
            print("최대 재연결 시도 횟수 초과")
            return
        }
        
        stopReconnectTimer()
        
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: reconnectDelay, repeats: false) { [weak self] _ in
            self?.attemptReconnect()
        }
    }
    
    private func attemptReconnect() {
        guard networkMonitor.isConnected else {
            print("네트워크 연결 없음 - 재연결 중단")
            return
        }
        
        reconnectAttempts += 1
        print("재연결 시도 \(reconnectAttempts)/\(maxReconnectAttempts)")
        
        connect()
        
        // 지수 백오프: 재연결 간격을 점진적으로 증가
        reconnectDelay = min(reconnectDelay * 2, 30) // 최대 30초
        
        // 연결 성공 시 재설정
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            if self?.connectionStatus == .connected {
                self?.resetReconnectState()
            } else {
                self?.reconnectWithDelay()
            }
        }
    }
    
    private func resetReconnectState() {
        reconnectAttempts = 0
        reconnectDelay = 1.0
        stopReconnectTimer()
    }
    
    private func stopReconnectTimer() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }
    
    override func connect() {
        super.connect()
        
        // 연결 성공 시 구독된 심볼들 재구독
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            if self?.connectionStatus == .connected {
                self?.resubscribeToSymbols()
                self?.resetReconnectState()
            }
        }
    }
    
    private func resubscribeToSymbols() {
        let symbolsToResubscribe = Array(subscribedSymbols)
        subscribedSymbols.removeAll()
        
        for symbol in symbolsToResubscribe {
            subscribe(to: symbol)
        }
    }
    
    deinit {
        stopReconnectTimer()
        NotificationCenter.default.removeObserver(self)
    }
}
