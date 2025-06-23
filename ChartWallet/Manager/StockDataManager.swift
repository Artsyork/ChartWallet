//
//  StockDataManager.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//  Updated by DY on 6/10/25.
//

import Foundation

class StockDataManager: NSObject, ObservableObject, URLSessionWebSocketDelegate {
    @Published var stocks: [StockItem] = []
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var lastAnalystUpdate: Date?
    @Published var nextAnalystUpdate: Date?
    @Published var lastPriceUpdate: Date?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private let finnhubAPIKey = BaseURL.FINNHUB_API_KEY.url
    private let fmpAPIKey = BaseURL.FMP_API_KEY.url
    
    private var analystUpdateTimer: Timer?
    private var priceUpdateTimer: Timer?
    private let analystCacheKey = "AnalystDataCache"
    private let lastUpdateKey = "LastAnalystUpdate"
    private let lastPriceUpdateKey = "LastPriceUpdate"
    
    // 현재 추적 중인 종목 심볼들
    private var trackedSymbols: [String] = []
    
    enum ConnectionStatus {
        case connected, disconnected, connecting
    }
    
    override init() {
        super.init()
        
        setupSession()
        loadCachedAnalystData()
        loadCachedPriceData()
        scheduleAnalystUpdates()
        scheduleRegularPriceUpdates()
    }
    
    // MARK: - Public Methods
    
    /// 추적할 종목 심볼들을 업데이트
    func updateStockSymbols(_ symbols: [String]) {
        let uniqueSymbols = Array(Set(symbols)).sorted()
        
        // 기존 종목들과 비교하여 변경사항이 있는지 확인
        if trackedSymbols != uniqueSymbols {
            trackedSymbols = uniqueSymbols
            updateStocksList()
            
            // WebSocket이 연결되어 있다면 새로운 구독 설정
            if connectionStatus == .connected {
                resubscribeToStocks()
            }
            
            // 애널리스트 데이터 업데이트
            //loadAnalystData()
        }
    }
    
    /// 종목에 대한 회사명을 가져오기 (기본값 제공)
    func getCompanyName(for symbol: String) -> String {
        // 인기 종목들의 회사명 매핑
        let companyNames: [String: String] = [
            "AAPL": "Apple Inc.",
            "GOOGL": "Alphabet Inc.",
            "MSFT": "Microsoft Corp.",
            "TSLA": "Tesla Inc.",
            "AMZN": "Amazon.com Inc.",
            "NVDA": "NVIDIA Corp.",
            "META": "Meta Platforms",
            "NFLX": "Netflix Inc.",
            "GOOG": "Alphabet Inc. (Class C)",
            "UBER": "Uber Technologies",
            "AMD": "Advanced Micro Devices",
            "INTC": "Intel Corp.",
            "BABA": "Alibaba Group",
            "COIN": "Coinbase Global",
            "PLTR": "Palantir Technologies"
        ]
        
        return companyNames[symbol] ?? "\(symbol) Inc."
    }
    
    private func updateStocksList() {
        var newStocks: [StockItem] = []
        
        for symbol in trackedSymbols {
            // 기존 주식 데이터가 있다면 유지, 없다면 새로 생성
            if let existingStock = stocks.first(where: { $0.symbol == symbol }) {
                newStocks.append(existingStock)
            } else {
                let newStock = StockItem(
                    symbol: symbol,
                    name: getCompanyName(for: symbol)
                )
                newStocks.append(newStock)
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.stocks = newStocks
        }
        
        print("📋 추적 종목 업데이트: \(trackedSymbols)")
    }
    
    private func resubscribeToStocks() {
        print("🔄 종목 재구독 시작...")
        
        // 기존 구독 해제는 생략 (Finnhub에서는 새 구독이 기존 것을 덮어씀)
        
        // 새로운 종목들 구독
        for symbol in trackedSymbols {
            let subscribeRequest = FinnhubWebSocket_API.Request(type: .subscribe, symbol: symbol)
            let subscribeMessage = ["type": subscribeRequest.type, "symbol": subscribeRequest.symbol]
            sendMessage(subscribeMessage)
            print("📤 \(symbol) 재구독 요청")
            
            Thread.sleep(forTimeInterval: 0.1) // 서버 부하 방지
        }
        
        print("✅ 종목 재구독 완료")
    }
    
    private func setupSession() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        
        config.httpAdditionalHeaders = [
            "User-Agent": "StockChartApp/1.0"
        ]
        
        urlSession = URLSession(
            configuration: config,
            delegate: self,
            delegateQueue: OperationQueue()
        )
        
        print("✅ URLSession 설정 완료")
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        connectionStatus = .disconnected
        analystUpdateTimer?.invalidate()
        analystUpdateTimer = nil
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
            //loadAnalystData()
            
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
        guard !finnhubAPIKey.isEmpty else {
            print("❌ Finnhub API 키가 설정되지 않았습니다!")
            print("💡 https://finnhub.io 에서 무료 API 키를 발급받으세요")
            return
        }
        
        print("🔍 설정된 API 키: \(String(finnhubAPIKey.prefix(20)))...")
        
        // 시장 시간 확인 후 연결 방식 결정
        if isMarketOpen() {
            print("✅ 미국 주식 시장 개장 시간 - WebSocket 연결 시도")
            // API 키 유효성 먼저 테스트
            testFinnhubAPIKey { [weak self] isValid in
                guard let self = self else { return }
                
                if isValid {
                    print("✅ API 키 검증 완료, WebSocket 연결 시작")
                    //self.connectWebSocket()
                } else {
                    print("❌ API 키가 유효하지 않습니다. REST API로 전환합니다.")
                    //self.fetchLatestPricesViaREST()
                }
            }
        } else {
            print("⚠️ 미국 주식 시장 시간 외 - REST API로 주가 조회")
            //fetchLatestPricesViaREST()
        }
    }
    
    private func testFinnhubAPIKey(completion: @escaping (Bool) -> Void) {
        print("🔍 Finnhub API 키 유효성 테스트 중...")
        
        let request = FinnhubQuote_API.Request(symbol: "AAPL", token: finnhubAPIKey)
        let urlString = "\(FinnhubQuote_API.endPoint)?symbol=\(request.symbol)&token=\(request.token)"
        
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
        // WebSocket API 모델 사용
        let path = FinnhubWebSocket_API.Path(token: finnhubAPIKey)
        let websocketURLString = "\(FinnhubWebSocket_API.endPoint)?token=\(path.token)"
        
        guard let url = URL(string: websocketURLString) else {
            print("❌ WebSocket URL 생성 실패")
            return
        }
        
        print("🔄 WebSocket 연결 시도...")
        print("📍 URL: \(url.absoluteString)")
        
        // 현재 시장 상태 체크
        let _ = isMarketOpen()
        
        connectionStatus = .connecting
        
        // 기존 연결 정리
        disconnect()
        
        // 새로운 WebSocket 작업 생성
        webSocketTask = urlSession?.webSocketTask(with: url)
        guard let task = webSocketTask else {
            print("❌ WebSocketTask 생성 실패")
            connectionStatus = .disconnected
            return
        }
        
        print("✅ WebSocketTask 생성 성공")
        task.resume()
        print("✅ WebSocketTask 시작됨")
        
        // 메시지 수신 시작
        receiveMessage()
        
        // 짧은 타임아웃으로 빠른 실패 감지 (5초)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self else { return }
            if self.connectionStatus == .connecting {
                print("⏰ WebSocket 연결 타임아웃 (5초)")
                print("💡 WebSocket 실패, REST API로 전환합니다")
                self.connectionStatus = .disconnected
                self.webSocketTask?.cancel()
                
                // REST API로 가격 데이터 가져오기
                //self.fetchLatestPricesViaREST()
            }
        }
        
        // 시장 종료 시간에 자동으로 REST API로 전환
        if isMarketOpen() {
            scheduleMarketCloseCheck()
        }
    }
    
    private func isMarketOpen() -> Bool {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "America/New_York")
        formatter.dateFormat = "EEEE HH:mm"
        let currentTimeString = formatter.string(from: now)
        
        var calendar = Calendar.current
        let nyTimeZone = TimeZone(identifier: "America/New_York")!
        calendar.timeZone = nyTimeZone
        let components = calendar.dateComponents([.weekday, .hour, .minute], from: now)
        let weekday = components.weekday ?? 0 // 1=일요일, 2=월요일, ..., 7=토요일
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        
        let isWeekend = weekday == 1 || weekday == 7 // 일요일 또는 토요일
        let currentMinutes = hour * 60 + minute
        let marketOpenMinutes = 9 * 60 + 30 // 09:30
        let marketCloseMinutes = 16 * 60 // 16:00
        
        // 현재 시장 상태 체크
        let isMarketHours = !isWeekend && currentMinutes >= marketOpenMinutes && currentMinutes < marketCloseMinutes
        
        print("🕐 현재 시간 (EST): \(currentTimeString)")
        print("📅 요일: \(weekday) (1=일요일)")
        print("🏢 주말 여부: \(isWeekend)")
        print("⏰ 시장 시간 여부: \(isMarketHours)")
        
        if isWeekend {
            print("⚠️ 주말 - 미국 주식 시장 휴장")
            print("💡 실시간 데이터가 제한적입니다. 테스트 데이터를 사용해보세요.")
        } else if !isMarketHours {
            print("⚠️ 미국 주식 시장 시간 외")
            print("💡 장중 시간: 월-금 09:30-16:00 EST")
            print("💡 실시간 데이터가 제한적입니다. 테스트 데이터를 사용해보세요.")
        } else {
            print("✅ 미국 주식 시장 개장 시간")
            print("💡 실시간 거래 데이터를 받을 수 있습니다")
        }
        
        return isMarketHours
    }
    
    private func scheduleMarketCloseCheck() {
        let calendar = Calendar.current
        let nyTimeZone = TimeZone(identifier: "America/New_York")!
        let now = Date()
        
        // 오늘 오후 4시 (시장 마감 시간) 계산
        guard let marketClose = calendar.dateBySettingTime(hour: 16, minute: 0, of: now) else {
            return
        }
        
        // 시장 마감까지의 시간 계산
        let timeUntilClose = marketClose.timeIntervalSince(now)
        
        if timeUntilClose > 0 {
            print("⏰ 시장 마감까지 \(Int(timeUntilClose/60))분 남음, 자동 전환 예약")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + timeUntilClose) { [weak self] in
                guard let self = self else { return }
                print("🔄 시장 마감 - WebSocket에서 REST API로 전환")
                self.disconnect()
                //self.fetchLatestPricesViaREST()
            }
        }
    }
    
    private func subscribeToStocks() {
        guard !trackedSymbols.isEmpty else {
            print("⚠️ 구독할 종목이 없습니다")
            return
        }
        
        print("📤 주식 구독 시작...")
        print("📋 구독할 종목: \(trackedSymbols)")
        
        for (index, symbol) in trackedSymbols.enumerated() {
            let subscribeRequest = FinnhubWebSocket_API.Request(type: .subscribe, symbol: symbol)
            let subscribeMessage = ["type": subscribeRequest.type, "symbol": subscribeRequest.symbol]
            sendMessage(subscribeMessage)
            print("📤 [\(index+1)/\(trackedSymbols.count)] \(symbol) 구독 요청")
            
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        print("✅ 모든 종목 구독 요청 완료")
        
        // 30초 후에도 데이터가 없으면 알림
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
            guard let self = self else { return }
            
            let stocksWithData = self.stocks.filter { $0.currentPrice > 0 }
            if stocksWithData.isEmpty {
                print("⚠️ 30초 동안 실시간 데이터를 받지 못했습니다")
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
                
                // API 모델을 사용한 데이터 파싱
                let response = try JSONDecoder().decode(FinnhubWebSocket_API.Response.self, from: data)
                
                if let tradeDataArray = response.data, !tradeDataArray.isEmpty {
                    print("✅ 거래 데이터 파싱 성공: \(tradeDataArray.count)개")
                    
                    // API Response를 StockTrade로 변환
                    let trades = tradeDataArray.map { tradeData in
                        StockTrade(
                            symbol: tradeData.s,
                            price: tradeData.p,
                            timestamp: Date(timeIntervalSince1970: TimeInterval(tradeData.t) / 1000.0),
                            volume: tradeData.v
                        )
                    }
                    
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
                
                // 현재 가격 업데이트
                stocks[index].currentPrice = trade.price
                
                // 가격 변화 계산
                if oldPrice > 0 {
                    stocks[index].priceChange = trade.price - oldPrice
                    stocks[index].priceChangePercent = ((trade.price - oldPrice) / oldPrice) * 100
                } else {
                    stocks[index].priceChange = 0
                    stocks[index].priceChangePercent = 0
                }
                
                // 차트 데이터 추가
                stocks[index].chartData.append(trade)
                if stocks[index].chartData.count > 50 {
                    stocks[index].chartData = Array(stocks[index].chartData.suffix(50))
                }
            } else {
                print("❌ \(trade.symbol) 종목을 찾을 수 없음")
                print("📋 현재 종목 리스트: \(stocks.map { $0.symbol })")
            }
        }
        
        print("🔄 전체 업데이트 완료")
    }
    
    private func loadAnalystData() {
        guard !fmpAPIKey.isEmpty else {
            print("❌ FMP API 키가 설정되지 않았습니다!")
            return
        }
        
        print("🔍 애널리스트 데이터 벌크 로드 시작")
                
        loadAnalystRecommendationBulk { [weak self] in
            DispatchQueue.main.async {
                self?.saveAnalystDataToCache()
                print("✅ 애널리스트 데이터 벌크 로드 완료")
            }
        }
    }
    
    private func loadAnalystRecommendationBulk(completion: @escaping () -> Void) {
        guard !trackedSymbols.isEmpty else {
            print("⚠️ 조회할 종목이 없습니다")
            completion()
            return
        }
        
        print("🔍 개별 종목 애널리스트 데이터 로드 시작 (무료 플랜)")
        print("📋 조회할 종목: \(trackedSymbols)")
        
        let group = DispatchGroup()
        var successCount = 0
        var errorCount = 0
        
        // 각 종목에 대해 개별적으로 API 호출
        for symbol in trackedSymbols {
            group.enter()
            loadIndividualAnalystData(symbol: symbol) { [weak self] result in
                defer { group.leave() }
                
                switch result {
                case .success(let recommendation):
                    DispatchQueue.main.async {
                        guard let self = self,
                              let index = self.stocks.firstIndex(where: { $0.symbol == symbol }) else {
                            return
                        }
                        
                        self.stocks[index].analystData = recommendation
                        successCount += 1
                        print("✅ \(symbol) 애널리스트 데이터 업데이트 완료")
                        
                        // 데이터 확인 로그
                        if let targetPrice = recommendation.analystTargetPrice {
                            print("   📊 목표가: $\(targetPrice)")
                        }
                        print("   📈 평가: \(recommendation.averageRating)")
                    }
                    
                case .failure(let error):
                    errorCount += 1
                    print("❌ \(symbol) 애널리스트 데이터 로드 실패: \(error.localizedDescription)")
                }
            }
            
            // API 호출 간격 (무료 플랜 rate limit 고려)
            Thread.sleep(forTimeInterval: 0.5)
        }
        
        group.notify(queue: .main) {
            print("📊 애널리스트 데이터 로드 완료: 성공 \(successCount)개, 실패 \(errorCount)개")
            completion()
        }
    }
    
    private func loadIndividualAnalystData(symbol: String, completion: @escaping (Result<AnalystRecommendation, Error>) -> Void) {
        // Grade API v3 사용 (무료 플랜에서 확실히 지원)
        let request = AnalystRecommendation_API.Request(symbol: symbol, apikey: fmpAPIKey)
        let urlString = "\(AnalystRecommendation_API.endPoint)/\(request.symbol)?limit=10&apikey=\(request.apikey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "URLError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        print("📡 \(symbol) 애널리스트 등급 데이터 조회: \(urlString)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // 응답 로깅 (처음 300자만)
            if let responseString = String(data: data, encoding: .utf8) {
                print("📊 \(symbol) API 응답: \(String(responseString.prefix(300)))")
                
                // 에러 메시지 체크
                if responseString.contains("Error Message") || responseString.contains("Exclusive Endpoint") {
                    let errorMsg = "API 엔드포인트가 현재 플랜에서 지원되지 않습니다"
                    print("⚠️ \(symbol): \(errorMsg)")
                    completion(.failure(NSError(domain: "APIError", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMsg])))
                    return
                }
                
                // 빈 배열 체크
                if responseString.trimmingCharacters(in: .whitespacesAndNewlines) == "[]" {
                    print("ℹ️ \(symbol): 애널리스트 등급 데이터 없음")
                    completion(.failure(NSError(domain: "NoDataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No analyst grade data available"])))
                    return
                }
            }
            
            do {
                // Grade API v3 응답 파싱 (배열 형태)
                let gradeResponses = try JSONDecoder().decode([AnalystRecommendation_API.Response].self, from: data)
                
                if let firstGrade = gradeResponses.first {
                    print("✅ \(symbol) 등급 데이터 파싱 성공: \(gradeResponses.count)개 등급")
                    
                    let recommendation = AnalystRecommendation(from: firstGrade, symbol: symbol)
                    completion(.success(recommendation))
                } else {
                    print("ℹ️ \(symbol): 등급 데이터 배열이 비어있음")
                    completion(.failure(NSError(domain: "NoDataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty analyst grades array"])))
                }
                
            } catch {
                print("❌ \(symbol) JSON 파싱 실패: \(error)")
                
                // 원시 응답 출력으로 디버깅 도움
                if let responseString = String(data: data, encoding: .utf8) {
                    print("❌ 파싱 실패한 원시 데이터: \(responseString)")
                }
                
                completion(.failure(error))
            }
        }.resume()
    }
    
    // 수동 업데이트 (운영용)
    func forceUpdateAnalystData() {
        print("🔄 애널리스트 데이터 수동 업데이트...")
        //loadAnalystData()
        calculateNextUpdateTime()
    }
    
    // MARK: - REST API Price Updates
    
    private func scheduleRegularPriceUpdates() {
        // 시장 개장 시간에는 5분마다, 시장 외 시간에는 30분마다 업데이트
        let updateInterval: TimeInterval = isMarketOpen() ? 300.0 : 1800.0
        
        priceUpdateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // WebSocket 연결이 없는 경우에만 REST API 호출
            if self.connectionStatus != .connected {
                //self.fetchLatestPricesViaREST()
            }
        }
        
        // 앱 시작 시 즉시 실행 (WebSocket 연결이 없는 경우)
        if connectionStatus != .connected {
            //fetchLatestPricesViaREST()
        }
    }
    
    private func fetchLatestPricesViaREST() {
        print("📡 REST API로 최신 가격 조회 중...")
        
        guard !finnhubAPIKey.isEmpty else {
            print("❌ API 키가 없습니다")
            return
        }
        
        guard !trackedSymbols.isEmpty else {
            print("⚠️ 조회할 종목이 없습니다")
            return
        }
        
        let group = DispatchGroup()
        
        for symbol in trackedSymbols {
            group.enter()
            fetchStockQuote(symbol: symbol) { [weak self] quote in
                defer { group.leave() }
                
                guard let self = self,
                      let index = self.stocks.firstIndex(where: { $0.symbol == symbol }) else {
                    return
                }
                
                DispatchQueue.main.async {
                    let oldPrice = self.stocks[index].currentPrice
                    self.stocks[index].currentPrice = quote.currentPrice
                    self.stocks[index].priceChange = quote.change
                    self.stocks[index].priceChangePercent = quote.changePercent
                    
                    print("📊 \(symbol): $\(oldPrice) → $\(quote.currentPrice) (\(quote.changePercent)%)")
                }
            }
        }
        
        group.notify(queue: .main) {
            self.lastPriceUpdate = Date()
            self.savePriceDataToCache()
            print("✅ 모든 주식 가격 업데이트 완료")
        }
    }
    
    private func fetchStockQuote(symbol: String, completion: @escaping (StockQuote) -> Void) {
        // API 모델 사용
        let request = FinnhubQuote_API.Request(symbol: symbol, token: finnhubAPIKey)
        let urlString = "\(FinnhubQuote_API.endPoint)?symbol=\(request.symbol)&token=\(request.token)"
        
        guard let url = URL(string: urlString) else {
            print("❌ \(symbol) URL 생성 실패")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ \(symbol) 조회 실패: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ \(symbol) 데이터 없음")
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(FinnhubQuote_API.Response.self, from: data)
                let quote = StockQuote(
                    symbol: symbol,
                    currentPrice: apiResponse.c,
                    change: apiResponse.d,
                    changePercent: apiResponse.dp
                )
                completion(quote)
            } catch {
                print("❌ \(symbol) JSON 파싱 실패: \(error)")
            }
        }.resume()
    }
    
    private func loadCachedPriceData() {
        if let lastUpdate = UserDefaults.standard.object(forKey: lastPriceUpdateKey) as? Date {
            lastPriceUpdate = lastUpdate
            print("📂 마지막 가격 업데이트: \(formatDate(lastUpdate))")
        }
    }
    
    private func savePriceDataToCache() {
        UserDefaults.standard.set(Date(), forKey: lastPriceUpdateKey)
        print("💾 가격 데이터 캐시 저장")
    }
}

// MARK: - URLSessionWebSocketDelegate Extension
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
