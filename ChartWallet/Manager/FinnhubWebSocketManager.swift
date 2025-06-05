//
//  FinnhubWebSocketManager.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import Foundation

class FinnhubWebSocketManager: NSObject, ObservableObject {
    @Published var trades: [StockTrade] = []
    @Published var currentPrice: Double = 0.0
    @Published var priceChange: Double = 0.0
    @Published var priceChangePercent: Double = 0.0
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var chartData: [StockTrade] = []
    @Published var dayHigh: Double = 0.0
    @Published var dayLow: Double = 0.0
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private let apiKey = BaseURL.FINNHUB_API_KEY.rawValue
    internal var subscribedSymbols: Set<String> = []
    private var lastPrice: Double = 0.0
    
    enum ConnectionStatus {
        case connected, disconnected, connecting
    }
    
    override init() {
        super.init()
        setupSession()
    }
    
    func testAPIKey() {
        guard !apiKey.isEmpty else {
            print("❌ API 키가 설정되지 않았습니다!")
            return
        }
        
        print("🔍 API 키 유효성 테스트 중...")
        
        let testUrlString = "https://finnhub.io/api/v1/quote?symbol=AAPL&token=\(apiKey)"
        guard let testUrl = URL(string: testUrlString) else {
            print("❌ Invalid REST API URL")
            return
        }
        
        URLSession.shared.dataTask(with: testUrl) { data, response, error in
            if let error = error {
                print("❌ REST API 에러: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP 상태 코드: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 429 {
                    print("⚠️ API 호출 한도 초과")
                } else if httpResponse.statusCode == 401 {
                    print("❌ API 키가 유효하지 않습니다")
                }
            }
            
            if let data = data,
               let responseString = String(data: data, encoding: .utf8) {
                print("📊 REST API 응답: \(responseString)")
                
                if responseString.contains("\"c\":") {
                    print("✅ API 키가 유효합니다!")
                }
            }
        }.resume()
    
        print("🧪 테스트 데이터 생성 시작")
        
        let symbols = ["AAPL", "GOOGL", "MSFT", "TSLA"]
        let basePrices = [180.0, 140.0, 380.0, 250.0]
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            // 랜덤 심볼과 가격 변동 생성
            let randomIndex = Int.random(in: 0..<symbols.count)
            let symbol = symbols[randomIndex]
            let basePrice = basePrices[randomIndex]
            let priceChange = Double.random(in: -5.0...5.0)
            let newPrice = basePrice + priceChange
            
            // 테스트 거래 데이터 생성
            let testTrade = StockTrade(
                symbol: symbol,
                price: newPrice,
                timestamp: Date(),
                volume: Int.random(in: 1000...50000)
            )
            
            print("🧪 테스트 거래 생성: \(symbol) - $\(String(format: "%.2f", newPrice))")
            
            DispatchQueue.main.async { [weak self] in
                self?.updateTrades([testTrade])
            }
        }
    }
    
    // StockTrade에 직접 초기화 추가를 위한 확장
    private func createTestTrade(symbol: String, price: Double, timestamp: Date, volume: Int) -> StockTrade {
        // JSON 데이터를 만들어서 디코딩하는 방식으로 테스트 데이터 생성
        let jsonData = """
        {
            "s": "\(symbol)",
            "p": \(price),
            "t": \(Int(timestamp.timeIntervalSince1970 * 1000)),
            "v": \(volume)
        }
        """.data(using: .utf8)!
        
        return try! JSONDecoder().decode(StockTrade.self, from: jsonData)
    }
    
    private func setupSession() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    func connect() {
        guard !apiKey.isEmpty && apiKey != "YOUR_FINNHUB_API_KEY" else {
            print("❌ API 키가 설정되지 않았습니다!")
            return
        }
        
        guard let url = URL(string: "wss://ws.finnhub.io?token=\(apiKey)") else {
            print("❌ Invalid WebSocket URL")
            return
        }
        
        print("🔄 WebSocket 연결 시도 중...")
        print("📍 URL: wss://ws.finnhub.io?token=\(String(apiKey.prefix(10)))...")
        
        // 시장 시간 체크
        checkMarketHours()
        
        connectionStatus = .connecting
        webSocketTask = urlSession?.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveMessage()
    }
    
    private func checkMarketHours() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "America/New_York")
        formatter.dateFormat = "HH:mm"
        let currentTime = formatter.string(from: now)
        
        formatter.dateFormat = "EEEE"
        let currentDay = formatter.string(from: now)
        
        let isWeekend = currentDay == "Saturday" || currentDay == "Sunday"
        let hour = Calendar.current.component(.hour, from: now)
        
        if isWeekend {
            print("⚠️ 주말 - 미국 주식 시장 휴장")
            print("💡 테스트 데이터를 생성하시겠습니까?")
        } else if hour < 9 || hour >= 16 { // EST 기준 대략적인 시간
            print("⚠️ 미국 주식 시장 시간 외 (현재 EST: \(currentTime))")
            print("💡 장중 시간: 09:30 - 16:00 EST")
        } else {
            print("✅ 미국 주식 시장 개장 시간")
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        connectionStatus = .disconnected
        subscribedSymbols.removeAll()
    }
    
    func subscribe(to symbol: String) {
        guard connectionStatus == .connected else {
            print("WebSocket not connected")
            return
        }
        
        let subscribeMessage = ["type": "subscribe", "symbol": symbol]
        sendMessage(subscribeMessage)
        subscribedSymbols.insert(symbol)
        
        // 새 심볼 구독 시 차트 데이터 초기화
        chartData.removeAll()
        dayHigh = 0.0
        dayLow = 0.0
    }
    
    func unsubscribe(from symbol: String) {
        guard connectionStatus == .connected else { return }
        
        let unsubscribeMessage = ["type": "unsubscribe", "symbol": symbol]
        sendMessage(unsubscribeMessage)
        subscribedSymbols.remove(symbol)
    }
    
    private func sendMessage(_ message: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: message),
              let string = String(data: data, encoding: .utf8) else {
            print("❌ 메시지 직렬화 실패")
            return
        }
        
        print("📤 전송 메시지: \(string)")
        let message = URLSessionWebSocketTask.Message.string(string)
        webSocketTask?.send(message) { [weak self] error in
            if let error = error {
                print("❌ WebSocket 전송 에러: \(error)")
            } else {
                print("✅ 메시지 전송 성공")
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                self.handleMessage(message)
                self.receiveMessage() // 다음 메시지 수신 대기
            case .failure(let error):
                print("❌ WebSocket 수신 에러: \(error)")
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.connectionStatus = .disconnected
                }
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            print("📥 수신 메시지: \(text)")
            
            // ping 메시지 처리
            if text.contains("\"type\":\"ping\"") {
                print("🏓 Ping 수신, Pong 응답 전송")
                let pongMessage = ["type": "pong"]
                sendMessage(pongMessage)
                return
            }
            
            guard let data = text.data(using: .utf8) else {
                print("❌ 텍스트를 데이터로 변환 실패")
                return
            }
            
            do {
                // 먼저 원시 JSON 파싱 시도
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("📊 파싱된 JSON: \(json)")
                    
                    // 구독 확인 메시지 체크
                    if let type = json["type"] as? String, type == "subscribe" {
                        print("✅ 구독 확인됨!")
                        return
                    }
                }
                
                let response = try JSONDecoder().decode(WebSocketMessage.self, from: data)
                
                if let trades = response.data, !trades.isEmpty {
                    print("✅ 거래 데이터 수신: \(trades.count)개")
                    for trade in trades {
                        print("📈 거래: \(trade.symbol) - $\(trade.price)")
                    }
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.updateTrades(trades)
                    }
                } else {
                    print("ℹ️ 거래 데이터 없음 또는 빈 배열")
                    if let type = response.type {
                        print("📝 메시지 타입: \(type)")
                    }
                }
            } catch {
                print("❌ JSON 디코딩 에러: \(error)")
                print("❌ 원시 데이터: \(text)")
                
                // 수동으로 파싱 시도 (디버깅용)
                if text.contains("\"data\":[") {
                    print("🔍 데이터 배열이 포함된 메시지 발견")
                }
            }
            
        case .data(let data):
            print("📥 바이너리 데이터 수신: \(data)")
            
        @unknown default:
            print("❓ 알 수 없는 메시지 타입")
        }
    }
    
    private func updateTrades(_ newTrades: [StockTrade]) {
        for trade in newTrades {
            trades.append(trade)
            
            // 현재 가격 업데이트
            if trade.price != currentPrice {
                lastPrice = currentPrice > 0 ? currentPrice : trade.price
                currentPrice = trade.price
                priceChange = currentPrice - lastPrice
                
                if lastPrice > 0 {
                    priceChangePercent = (priceChange / lastPrice) * 100
                }
            }
            
            // 일일 최고/최저가 업데이트
            if dayHigh == 0 || trade.price > dayHigh {
                dayHigh = trade.price
            }
            if dayLow == 0 || trade.price < dayLow {
                dayLow = trade.price
            }
            
            // 차트 데이터 업데이트 (최근 100개 데이터만 유지)
            chartData.append(trade)
            if chartData.count > 100 {
                chartData = Array(chartData.suffix(100))
            }
        }
        
        // 전체 거래 내역도 최근 50개만 유지
        if trades.count > 50 {
            trades = Array(trades.suffix(50))
        }
    }
}

// MARK: - URLSessionWebSocketDelegate
extension FinnhubWebSocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.connectionStatus = .connected
            print("✅ WebSocket 연결 성공!")
            
            // API 키 유효성 테스트
            self.testAPIKey()
            
            // 연결 성공 후 자동으로 기본 심볼 구독
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let self = self else { return }
                if self.subscribedSymbols.isEmpty {
                    print("🔄 자동으로 AAPL 구독 시도")
                    self.subscribe(to: "AAPL")
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.connectionStatus = .disconnected
            print("❌ WebSocket 연결 해제됨. 코드: \(closeCode.rawValue)")
            if let reason = reason, let reasonString = String(data: reason, encoding: .utf8) {
                print("❌ 해제 이유: \(reasonString)")
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                print("❌ URLSession 에러: \(error.localizedDescription)")
                self.connectionStatus = .disconnected
            }
        }
    }
}
