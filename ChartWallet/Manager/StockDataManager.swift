//
//  StockDataManager.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import Foundation

class StockDataManager: NSObject, ObservableObject, URLSessionDelegate {
    
    @Published var stocks: [StockItem] = []
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var lastAnalystUpdate: Date?
    @Published var nextAnalystUpdate: Date?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private let finnhubAPIKey = BaseURL.FINNHUB_API_KEY.rawValue
    private let fmpAPIKey = BaseURL.FMP_API_KEY.rawValue
    
    private var analystUpdateTimer: Timer?
    private let analystCacheKey = "AnalystDataCache"
    private let lastUpdateKey = "LastAnalystUpdate"
    
    private let stockSymbols = [
        ("AAPL", "Apple Inc."),
        ("GOOGL", "Alphabet Inc."),
        ("MSFT", "Microsoft Corp."),
        ("TSLA", "Tesla Inc."),
        ("AMZN", "Amazon.com Inc."),
        ("NVDA", "NVIDIA Corp."),
        ("META", "Meta Platforms"),
        ("NFLX", "Netflix Inc.")
    ]
    
    enum ConnectionStatus {
        case connected, disconnected, connecting
    }
    
    override init() {
        super.init()
        setupStocks()
        setupSession()
        loadCachedAnalystData()
        scheduleAnalystUpdates()
    }
    
    deinit {
        analystUpdateTimer?.invalidate()
    }
    
    private func setupStocks() {
        stocks = stockSymbols.map { symbol, name in
            StockItem(symbol: symbol, name: name)
        }
    }
    
    private func setupSession() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    // MARK: - Analyst Data Caching & Scheduling
    
    private func scheduleAnalystUpdates() {
        // 마지막 업데이트 시간 확인
        if let lastUpdate = UserDefaults.standard.object(forKey: lastUpdateKey) as? Date {
            lastAnalystUpdate = lastUpdate
            print("📅 마지막 애널리스트 데이터 업데이트: \(formatDate(lastUpdate))")
        }
        
        calculateNextUpdateTime()
        
        // 하루에 두 번 업데이트 스케줄 (오전 9시, 오후 6시)
        analystUpdateTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.checkAndUpdateAnalystData()
        }
        
        // 앱 시작 시 즉시 체크
        checkAndUpdateAnalystData()
    }
    
    private func calculateNextUpdateTime() {
        let now = Date()
        let calendar = Calendar.current
        
        // 오늘의 오전 9시와 오후 6시
        guard let morning = calendar.dateBySettingTime(hour: 9, of: now),
              let evening = calendar.dateBySettingTime(hour: 18, of: now) else {
            print("❌ 시간 계산 실패")
            return
        }
        
        // 다음 업데이트 시간 결정
        if now < morning {
            nextAnalystUpdate = morning
        } else if now < evening {
            nextAnalystUpdate = evening
        } else {
            // 내일 오전 9시
            guard let tomorrowMorning = calendar.date(byAdding: .day, value: 1, to: morning) else {
                print("❌ 내일 시간 계산 실패")
                return
            }
            nextAnalystUpdate = tomorrowMorning
        }
        
        if let nextUpdate = nextAnalystUpdate {
            print("⏰ 다음 애널리스트 데이터 업데이트: \(formatDate(nextUpdate))")
        }
    }
    
    private func checkAndUpdateAnalystData() {
        let calendar = Calendar.current
        let now = Date()
        
        guard let nextUpdate = nextAnalystUpdate else { return }
        
        // 업데이트 시간이 되었는지 확인
        if now >= nextUpdate {
            print("🔄 애널리스트 데이터 업데이트 시작...")
            loadAnalystData()
            
            // 다음 업데이트 시간 계산
            calculateNextUpdateTime()
        }
    }
    
    private func loadCachedAnalystData() {
        guard let data = UserDefaults.standard.data(forKey: analystCacheKey),
              let cachedData = try? JSONDecoder().decode([String: AnalystRecommendation].self, from: data) else {
            print("📂 캐시된 애널리스트 데이터가 없습니다")
            return
        }
        
        print("📂 캐시된 애널리스트 데이터 로드됨")
        
        // 캐시된 데이터를 stocks에 적용
        for i in 0..<stocks.count {
            if let recommendation = cachedData[stocks[i].symbol] {
                stocks[i].analystData = recommendation
            }
        }
    }
    
    private func saveAnalystDataToCache() {
        var cacheData: [String: AnalystRecommendation] = [:]
        
        for stock in stocks {
            if let analystData = stock.analystData {
                cacheData[stock.symbol] = analystData
            }
        }
        
        if let data = try? JSONEncoder().encode(cacheData) {
            UserDefaults.standard.set(data, forKey: analystCacheKey)
            UserDefaults.standard.set(Date(), forKey: lastUpdateKey)
            lastAnalystUpdate = Date()
            print("💾 애널리스트 데이터 캐시 저장 완료")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    func connect() {
        guard !finnhubAPIKey.isEmpty && finnhubAPIKey != "YOUR_FINNHUB_API_KEY" else {
            print("❌ Finnhub API 키가 설정되지 않았습니다!")
            print("💡 https://finnhub.io 에서 무료 API 키를 발급받으세요")
            return
        }
        
        // API 키 유효성 먼저 테스트
        testFinnhubAPIKey { [weak self] isValid in
            guard let self = self else { return }
            
            if isValid {
                self.connectWebSocket()
            } else {
                print("❌ API 키가 유효하지 않습니다. WebSocket 연결을 중단합니다.")
            }
        }
    }
    
    private func testFinnhubAPIKey(completion: @escaping (Bool) -> Void) {
        print("🔍 Finnhub API 키 유효성 테스트 중...")
        
        let urlString = "https://finnhub.io/api/v1/quote?symbol=AAPL&token=\(finnhubAPIKey)"
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ REST API 테스트 에러: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 HTTP 상태 코드: \(httpResponse.statusCode)")
                    
                    switch httpResponse.statusCode {
                    case 200:
                        print("✅ Finnhub API 키가 유효합니다!")
                        completion(true)
                        return
                    case 401:
                        print("❌ API 키가 유효하지 않습니다 (401 Unauthorized)")
                        print("💡 API 키를 확인하고 다시 시도하세요")
                        completion(false)
                        return
                    case 429:
                        print("⚠️ API 호출 한도 초과 (429 Too Many Requests)")
                        print("💡 잠시 후 다시 시도하거나 유료 플랜을 고려하세요")
                        completion(false)
                        return
                    case 403:
                        print("❌ API 접근 권한이 없습니다 (403 Forbidden)")
                        completion(false)
                        return
                    default:
                        print("⚠️ 예상치 못한 상태 코드: \(httpResponse.statusCode)")
                        completion(false)
                        return
                    }
                }
                
                if let data = data,
                   let responseString = String(data: data, encoding: .utf8) {
                    print("📊 REST API 응답: \(responseString)")
                    
                    if responseString.contains("\"c\":") && !responseString.contains("error") {
                        print("✅ API 응답 데이터 정상!")
                        completion(true)
                    } else {
                        print("❌ API 응답에 오류가 있습니다")
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            }
        }.resume()
    }
    
    private func connectWebSocket() {
        guard let url = URL(string: "wss://ws.finnhub.io?token=\(finnhubAPIKey)") else {
            print("❌ Invalid WebSocket URL")
            return
        }
        
        print("🔄 WebSocket 연결 시도 중...")
        print("📍 URL: wss://ws.finnhub.io?token=\(String(finnhubAPIKey.prefix(10)))...")
        
        // 현재 시장 상태 체크
        checkCurrentMarketStatus()
        
        connectionStatus = .connecting
        webSocketTask = urlSession?.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveMessage()
        
        // 연결 타임아웃 체크 (10초)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self = self else { return }
            if self.connectionStatus == .connecting {
                print("⏰ WebSocket 연결 타임아웃")
                self.connectionStatus = .disconnected
                self.webSocketTask?.cancel()
            }
        }
    }
    
    private func checkCurrentMarketStatus() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "America/New_York")
        formatter.dateFormat = "EEEE HH:mm"
        let currentTimeString = formatter.string(from: now)
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday, .hour, .minute], from: now)
        let weekday = components.weekday ?? 0 // 1=일요일, 2=월요일, ..., 7=토요일
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        
        let isWeekend = weekday == 1 || weekday == 7 // 일요일 또는 토요일
        let currentMinutes = hour * 60 + minute
        let marketOpenMinutes = 9 * 60 + 30 // 09:30
        let marketCloseMinutes = 16 * 60 // 16:00
        
        let isMarketHours = !isWeekend &&
                           currentMinutes >= marketOpenMinutes &&
                           currentMinutes < marketCloseMinutes
        
        if isWeekend {
            print("⚠️ 주말 - 미국 주식 시장 휴장 (\(currentTimeString) EST)")
            print("💡 실시간 데이터가 제한적일 수 있습니다")
        } else if !isMarketHours {
            print("⚠️ 미국 주식 시장 시간 외 (\(currentTimeString) EST)")
            print("💡 장중 시간: 월-금 09:30-16:00 EST")
            print("💡 실시간 데이터가 제한적일 수 있습니다")
        } else {
            print("✅ 미국 주식 시장 개장 시간 (\(currentTimeString) EST)")
            print("💡 실시간 거래 데이터를 받을 수 있습니다")
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        connectionStatus = .disconnected
        analystUpdateTimer?.invalidate()
        analystUpdateTimer = nil
    }
    
    private func subscribeToStocks() {
        print("📤 주식 구독 시작...")
        print("📋 구독할 종목: \(stocks.map { $0.symbol })")
        
        for (index, stock) in stocks.enumerated() {
            let subscribeMessage = ["type": "subscribe", "symbol": stock.symbol]
            sendMessage(subscribeMessage)
            print("📤 [\(index+1)/\(stocks.count)] \(stock.symbol) 구독 요청")
            
            // 구독 요청 간격을 둠 (서버 부하 방지)
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        print("✅ 모든 종목 구독 요청 완료")
        print("⏳ 실시간 데이터 수신 대기 중...")
        
        // 30초 후에도 데이터가 없으면 알림
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
            guard let self = self else { return }
            
            let stocksWithData = self.stocks.filter { $0.currentPrice > 0 }
            if stocksWithData.isEmpty {
                print("⚠️ 30초 동안 실시간 데이터를 받지 못했습니다")
                print("💡 시장 시간을 확인하거나 테스트 데이터를 사용해보세요")
                print("💡 시장 시간: 월-금 09:30-16:00 EST")
            } else {
                print("✅ \(stocksWithData.count)개 종목의 데이터 수신 중")
            }
        }
    }
    
    private func sendMessage(_ message: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: message),
              let string = String(data: data, encoding: .utf8) else {
            return
        }
        
        let wsMessage = URLSessionWebSocketTask.Message.string(string)
        webSocketTask?.send(wsMessage) { error in
            if let error = error {
                print("❌ WebSocket 전송 에러: \(error)")
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                self.handleMessage(message)
                self.receiveMessage()
            case .failure(let error):
                print("❌ WebSocket 수신 에러: \(error)")
                DispatchQueue.main.async {
                    self.connectionStatus = .disconnected
                }
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            // ping 메시지는 조용히 처리
            if text.contains("\"type\":\"ping\"") {
                let pongMessage = ["type": "pong"]
                sendMessage(pongMessage)
                return
            }
            
            print("📥 수신 메시지: \(text)")
            
            guard let data = text.data(using: .utf8) else {
                print("❌ 텍스트를 데이터로 변환 실패")
                return
            }
            
            do {
                // 먼저 원시 JSON 파싱으로 메시지 타입 확인
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    
                    if let type = json["type"] as? String {
                        print("📋 메시지 타입: \(type)")
                        
                        switch type {
                        case "subscribe":
                            if let symbol = json["symbol"] as? String {
                                print("✅ \(symbol) 구독 확인됨")
                            }
                            return
                        case "error":
                            if let msg = json["msg"] as? String {
                                print("❌ 서버 에러: \(msg)")
                            }
                            return
                        case "trade":
                            print("📈 거래 데이터 메시지 확인")
                        default:
                            print("ℹ️ 기타 메시지 타입: \(type)")
                        }
                    }
                }
                
                // StockTrade 데이터 파싱 시도
                let response = try JSONDecoder().decode(WebSocketMessage.self, from: data)
                
                if let trades = response.data, !trades.isEmpty {
                    print("✅ 거래 데이터 파싱 성공: \(trades.count)개")
                    
                    for trade in trades {
                        print("📊 거래 상세: \(trade.symbol) - $\(trade.price) at \(trade.timestamp)")
                    }
                    
                    DispatchQueue.main.async {
                        self.updateStockData(trades)
                    }
                } else {
                    print("ℹ️ 거래 데이터 없음")
                    if let type = response.type {
                        print("📝 응답 타입: \(type)")
                    }
                }
            } catch {
                print("❌ JSON 디코딩 에러: \(error)")
                print("❌ 원시 데이터: \(text)")
                
                // 수동 파싱으로 문제 진단
                if text.contains("\"data\":[") {
                    print("🔍 데이터 배열이 포함된 메시지 발견")
                    if text.contains("\"s\":") && text.contains("\"p\":") {
                        print("🔍 거래 데이터 구조 확인됨")
                    }
                }
            }
            
        case .data(let data):
            print("📥 바이너리 데이터 수신: \(data)")
            
        @unknown default:
            print("❓ 알 수 없는 메시지 타입")
        }
    }
    
    private func updateStockData(_ trades: [StockTrade]) {
        print("📊 업데이트할 거래 데이터: \(trades.count)개")
        
        for trade in trades {
            print("📈 처리 중인 거래: \(trade.symbol) - $\(trade.price)")
            
            if let index = stocks.firstIndex(where: { $0.symbol == trade.symbol }) {
                print("✅ \(trade.symbol) 종목 찾음 (인덱스: \(index))")
                
                let oldPrice = stocks[index].currentPrice
                print("📊 \(trade.symbol) 이전 가격: $\(oldPrice) → 새 가격: $\(trade.price)")
                
                // 현재 가격 업데이트
                stocks[index].currentPrice = trade.price
                
                // 가격 변화 계산
                if oldPrice > 0 {
                    stocks[index].priceChange = trade.price - oldPrice
                    stocks[index].priceChangePercent = ((trade.price - oldPrice) / oldPrice) * 100
                    print("📊 \(trade.symbol) 변화: $\(stocks[index].priceChange) (\(stocks[index].priceChangePercent)%)")
                } else {
                    print("📊 \(trade.symbol) 첫 거래 데이터")
                    stocks[index].priceChange = 0
                    stocks[index].priceChangePercent = 0
                }
                
                // 차트 데이터 추가
                stocks[index].chartData.append(trade)
                if stocks[index].chartData.count > 50 {
                    stocks[index].chartData = Array(stocks[index].chartData.suffix(50))
                }
                
                print("✅ \(trade.symbol) 업데이트 완료 - 현재가: $\(stocks[index].currentPrice)")
            } else {
                print("❌ \(trade.symbol) 종목을 찾을 수 없음")
                print("📋 현재 종목 리스트: \(stocks.map { $0.symbol })")
            }
        }
        
        print("🔄 전체 업데이트 완료")
    }
    
    private func loadAnalystData() {
        guard !fmpAPIKey.isEmpty && fmpAPIKey != "YOUR_FMP_API_KEY" else {
            print("❌ FMP API 키가 설정되지 않았습니다!")
            return
        }
        
        print("🔍 애널리스트 데이터 로드 시작 (하루 2회 제한)")
        
        let group = DispatchGroup()
        
        for stock in stocks {
            group.enter()
            loadAnalystRecommendation(for: stock.symbol) {
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.saveAnalystDataToCache()
            print("✅ 모든 애널리스트 데이터 로드 완료")
        }
    }
    
    private func loadAnalystRecommendation(for symbol: String, completion: @escaping () -> Void) {
        let urlString = "https://financialmodelingprep.com/api/v3/analyst-stock-recommendations/\(symbol)?apikey=\(fmpAPIKey)"
        
        guard let url = URL(string: urlString) else {
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            defer { completion() }
            
            if let error = error {
                print("❌ \(symbol) 애널리스트 데이터 로드 실패: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ \(symbol) 데이터 없음")
                return
            }
            
            do {
                let recommendations = try JSONDecoder().decode([AnalystRecommendation].self, from: data)
                
                if let recommendation = recommendations.first {
                    DispatchQueue.main.async {
                        if let index = self?.stocks.firstIndex(where: { $0.symbol == symbol }) {
                            self?.stocks[index].analystData = recommendation
                            print("✅ \(symbol) 애널리스트 데이터 업데이트 완료")
                        }
                    }
                }
            } catch {
                print("❌ \(symbol) JSON 파싱 실패: \(error)")
            }
        }.resume()
    }
    
    // 수동 업데이트 (테스트용)
    func forceUpdateAnalystData() {
        print("🔄 애널리스트 데이터 수동 업데이트...")
        loadAnalystData()
        calculateNextUpdateTime()
    }
    
    func generateTestData() {
        print("🧪 테스트 데이터 생성 시작")
        
        let testSymbols = ["AAPL", "GOOGL", "MSFT", "TSLA", "AMZN", "NVDA", "META", "NFLX"]
        let basePrices: [String: Double] = [
            "AAPL": 180.0,
            "GOOGL": 140.0,
            "MSFT": 380.0,
            "TSLA": 250.0,
            "AMZN": 150.0,
            "NVDA": 450.0,
            "META": 320.0,
            "NFLX": 420.0
        ]
        
        // 초기 가격 설정 (첫 실행시)
        for symbol in testSymbols {
            if let index = stocks.firstIndex(where: { $0.symbol == symbol }),
               stocks[index].currentPrice == 0 {
                let basePrice = basePrices[symbol] ?? 100.0
                stocks[index].currentPrice = basePrice
                print("📊 \(symbol) 초기 가격 설정: $\(basePrice)")
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            print("🧪 테스트 데이터 생성 중...")
            
            for symbol in testSymbols {
                if let index = self.stocks.firstIndex(where: { $0.symbol == symbol }) {
                    let currentPrice = self.stocks[index].currentPrice
                    let basePrice = currentPrice > 0 ? currentPrice : (basePrices[symbol] ?? 100.0)
                    
                    // 더 현실적인 가격 변동 (-2% ~ +2%)
                    let changePercent = Double.random(in: -0.02...0.02)
                    let newPrice = max(basePrice * (1 + changePercent), 0.01)
                    
                    let testTrade = StockTrade(
                        symbol: symbol,
                        price: newPrice,
                        timestamp: Date(),
                        volume: Int.random(in: 1000...50000)
                    )
                    
                    print("🧪 생성된 테스트 거래: \(symbol) $\(basePrice) → $\(newPrice)")
                    
                    DispatchQueue.main.async {
                        self.updateStockData([testTrade])
                    }
                }
            }
        }
    }
    
}

extension StockDataManager {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        DispatchQueue.main.async {
            self.connectionStatus = .connected
            print("✅ WebSocket 연결 성공!")
            self.subscribeToStocks()
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        DispatchQueue.main.async {
            self.connectionStatus = .disconnected
            print("❌ WebSocket 연결 해제됨")
            print("📋 종료 코드: \(closeCode.rawValue)")
            
            if let reason = reason, let reasonString = String(data: reason, encoding: .utf8) {
                print("📋 종료 이유: \(reasonString)")
            }
            
            // 일반적인 종료 코드 해석
            switch closeCode {
            case .normalClosure:
                print("ℹ️ 정상 종료")
            case .goingAway:
                print("ℹ️ 서버 또는 클라이언트가 종료됨")
            case .protocolError:
                print("❌ 프로토콜 오류")
            case .unsupportedData:
                print("❌ 지원되지 않는 데이터 타입")
            case .noStatusReceived:
                print("❌ 상태 코드를 받지 못함")
            case .abnormalClosure:
                print("❌ 비정상 종료")
            case .invalidFramePayloadData:
                print("❌ 잘못된 프레임 데이터")
            case .policyViolation:
                print("❌ 정책 위반")
            case .messageTooBig:
                print("❌ 메시지가 너무 큼")
            case .internalServerError:
                print("❌ 서버 내부 오류")
            @unknown default:
                print("❓ 알 수 없는 종료 코드: \(closeCode.rawValue)")
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            DispatchQueue.main.async {
                print("❌ URLSession 작업 완료 시 오류: \(error.localizedDescription)")
                
                // NSURLError 코드별 상세 분석
                let nsError = error as NSError
                print("📋 오류 도메인: \(nsError.domain)")
                print("📋 오류 코드: \(nsError.code)")
                
                switch nsError.code {
                case NSURLErrorBadServerResponse: // -1011
                    print("💡 해결 방법:")
                    print("   1. API 키가 올바른지 확인")
                    print("   2. API 키에 WebSocket 권한이 있는지 확인")
                    print("   3. 무료 플랜의 경우 제한사항 확인")
                    print("   4. Finnhub 서비스 상태 확인")
                case NSURLErrorNotConnectedToInternet: // -1009
                    print("💡 인터넷 연결을 확인하세요")
                case NSURLErrorTimedOut: // -1001
                    print("💡 연결 시간이 초과되었습니다")
                case NSURLErrorCannotFindHost: // -1003
                    print("💡 호스트를 찾을 수 없습니다")
                case NSURLErrorSecureConnectionFailed: // -1200
                    print("💡 보안 연결에 실패했습니다")
                default:
                    print("💡 일반적인 네트워크 오류")
                }
                
                self.connectionStatus = .disconnected
            }
        }
    }
}
