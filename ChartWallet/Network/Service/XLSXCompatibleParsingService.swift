//
//  XLSXCompatibleParsingService.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import Foundation

final class XLSXCompatibleParsingService {

    /// 주식 라인 파싱 (ExcelStockDataKr 모델에 맞춤)
    private static func parseStockLine(_ line: String, lineNumber: Int) throws -> ExcelStockData? {
        let columns = smartSplitLine(line)
        
        print("🔍 라인 \(lineNumber): \(columns.count)개 컬럼")
        print("   처음 12개: \(Array(columns.prefix(12)))")
        
        guard columns.count >= 2 else {
            print("⚠️ 컬럼 수 부족")
            return nil
        }
        
        // 빈 라인 스킵
        if columns.allSatisfy({ $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            return nil
        }
        
        // 데이터 추출
        let seq = safeParseInt(columns[safe: 0]) ?? lineNumber
        let companyName = cleanString(columns[safe: 1])
        
        // 회사명 검증
        guard let validCompanyName = companyName,
              validCompanyName.count > 1 else {
            print("⚠️ 회사명 없음")
            return nil
        }
        
        // 예상 수익률 디버깅 (8번째 컬럼만 특별 처리)
        if let returnColumn = columns[safe: 8] {
            print("📊 예상 수익률 원본: '\(returnColumn)'")
            let parsedReturn = safeParsePercentage(returnColumn) // 퍼센트 전용 파싱
            print("📊 파싱된 수익률: \(parsedReturn ?? 0)%")
        }
        
        // ExcelStockDataKr 생성 (새로운 순서에 맞춤)
        return ExcelStockData(
            seq: seq,                                              // 1. 순번
            companyName: validCompanyName,                         // 2. 회사명
            currentPrice: safeParseDouble(columns[safe: 2]),       // 3. 현재가 (원화)
            sector: cleanString(columns[safe: 3]),                 // 4. 섹터
            industry: cleanString(columns[safe: 4]),               // 5. 산업
            analystRating: cleanString(columns[safe: 5]),          // 6. 애널리스트 평가
            analystTargetPrice: safeParseDouble(columns[safe: 6]), // 7. 애널리스트 목표가
            expectedReturn: safeParsePercentage(columns[safe: 7]), // 8. 예상 수익률 (퍼센트 파싱)
            week52High: safeParseDouble(columns[safe: 8]),         // 9. 52주 최고가
            week52Low: safeParseDouble(columns[safe: 9]),          // 10. 52주 최저가
            allTimeHigh: safeParseDouble(columns[safe: 10]),       // 11. 사상 최고가
            country: .KR                                           // 기본값: 한국
        )
    }
    
    /// 퍼센트 전용 파싱 함수 (예상 수익률 컬럼 전용)
    private static func safeParsePercentage(_ string: String?) -> Double? {
        guard let cleaned = cleanString(string) else {
            return nil
        }
        
        // 1단계: 기본 정리
        var numberString = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 2단계: 따옴표 제거
        numberString = numberString.replacingOccurrences(of: "\"", with: "")
                                  .replacingOccurrences(of: "'", with: "")
        
        // 3단계: % 기호와 관련 문자 제거
        numberString = numberString.replacingOccurrences(of: "%", with: "")
                                  .replacingOccurrences(of: "％", with: "") // 전각 퍼센트
                                  .replacingOccurrences(of: "percent", with: "", options: .caseInsensitive)
                                  .replacingOccurrences(of: "퍼센트", with: "")
                                  .replacingOccurrences(of: "프로", with: "")
        
        // 4단계: 공백과 쉼표 제거
        numberString = numberString.replacingOccurrences(of: " ", with: "")
                                  .replacingOccurrences(of: ",", with: "")
                                  .replacingOccurrences(of: "\t", with: "")
        
        // 5단계: 기타 불필요한 문자 제거
        numberString = numberString.replacingOccurrences(of: "(", with: "")
                                  .replacingOccurrences(of: ")", with: "")
                                  .replacingOccurrences(of: "[", with: "")
                                  .replacingOccurrences(of: "]", with: "")
        
        // 6단계: 최종 정리
        numberString = numberString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 빈 문자열 체크
        guard !numberString.isEmpty else {
            return nil
        }
        
        // Double 변환 시도
        return Double(numberString)
    }

    /// 개선된 일반 숫자 파싱 (% 기호도 처리)
    private static func safeParseDouble(_ string: String?) -> Double? {
        guard let cleaned = cleanString(string) else { return nil }
        
        // % 기호가 포함되어 있으면 퍼센트로 처리
        if cleaned.contains("%") || cleaned.contains("％") {
            return safeParsePercentage(string)
        }
        
        let numberString = cleaned.replacingOccurrences(of: ",", with: "")
                                 .replacingOccurrences(of: "원", with: "")
                                 .replacingOccurrences(of: "$", with: "")
                                 .replacingOccurrences(of: " ", with: "")
                                 .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return Double(numberString)
    }

    /// 개선된 문자열 정리
    private static func cleanString(_ string: String?) -> String? {
        guard let string = string?.trimmingCharacters(in: .whitespacesAndNewlines),
              !string.isEmpty else { return nil }
        
        // 빈 값들
        let emptyValues = ["-", "--", "N/A", "NULL", "없음", "n/a", "null", "N/a"]
        let lowercased = string.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if emptyValues.contains(lowercased) { return nil }
        
        // 기본 정리
        let cleaned = string.replacingOccurrences(of: "\"", with: "")
                           .replacingOccurrences(of: "'", with: "")
                           .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned.isEmpty ? nil : cleaned
    }

    /// 스마트 라인 분리 (개선된 CSV 파싱)
    private static func smartSplitLine(_ line: String) -> [String] {
        // CSV 우선 처리
        if line.contains(",") {
            return parseCSVLine(line)
        } else if line.contains("\t") {
            return line.components(separatedBy: "\t")
        } else if line.contains(";") {
            return line.components(separatedBy: ";")
        } else if line.contains("|") {
            return line.components(separatedBy: "|")
        } else {
            return line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        }
    }

    /// 향상된 CSV 라인 파싱 (따옴표와 % 처리)
    private static func parseCSVLine(_ line: String) -> [String] {
        var columns: [String] = []
        var currentColumn = ""
        var insideQuotes = false
        
        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                // 컬럼 완료 - 정리해서 추가
                let cleanedColumn = currentColumn.trimmingCharacters(in: .whitespacesAndNewlines)
                columns.append(cleanedColumn)
                currentColumn = ""
            } else {
                currentColumn.append(char)
            }
        }
        
        // 마지막 컬럼 추가
        let cleanedColumn = currentColumn.trimmingCharacters(in: .whitespacesAndNewlines)
        columns.append(cleanedColumn)
        
        // 결과 로깅
        print("📝 CSV 파싱 결과: \(columns.count)개 컬럼")
        for (i, col) in columns.enumerated() {
            if col.contains("%") {
                print("   [\(i)]: '\(col)' ← 퍼센트 포함!")
            }
        }
        
        return columns
    }
    
    /// XLSX 호환 파일 파싱
    static func parseExcelFile(at url: URL) throws -> [ExcelStockData] {
        let fileExtension = url.pathExtension.lowercased()
        
        print("📂 파일: \(url.lastPathComponent)")
        print("📂 확장자: \(fileExtension)")
        
        // 파일 존재 확인
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ExcelParsingError.fileNotFound
        }
        
        // 파일 크기 확인
        let fileSize = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int ?? 0
        print("📏 파일 크기: \(fileSize) bytes")
        
        guard fileSize > 0 else {
            throw ExcelParsingError.emptyFile
        }
        
        // 파일 타입에 따른 처리
        switch fileExtension {
        case "xlsx":
            return try parseXLSXFile(at: url)
        case "xls":
            return try parseXLSFile(at: url)
        case "csv":
            return try parseCSVFile(at: url)
        default:
            // 확장자 상관없이 내용 기반으로 판단
            return try parseUnknownFile(at: url)
        }
    }
    
    /// XLSX 파일 처리 (ZIP 구조 감지)
    private static func parseXLSXFile(at url: URL) throws -> [ExcelStockData] {
        print("📊 XLSX 파일 처리 시작")
        
        let data = try Data(contentsOf: url)
        
        // ZIP 파일 시그니처 확인 (XLSX는 ZIP 기반)
        if isZipFile(data: data) {
            print("✅ XLSX ZIP 구조 감지")
            // XLSX는 복잡한 ZIP+XML 구조이므로 CSV 변환 안내
            throw XLSXError.needsCSVConversion
        } else {
            print("⚠️ XLSX가 아닌 텍스트 파일로 판단, CSV 방식으로 처리")
            return try parseAsCSV(data: data, filename: url.lastPathComponent)
        }
    }
    
    /// XLS 파일 처리 (레거시 Excel)
    private static func parseXLSFile(at url: URL) throws -> [ExcelStockData] {
        print("📊 XLS 파일 처리 시작")
        
        let data = try Data(contentsOf: url)
        
        // XLS 파일 시그니처 확인
        if isXLSFile(data: data) {
            print("✅ XLS 바이너리 구조 감지")
            throw XLSXError.needsCSVConversion
        } else {
            print("⚠️ XLS가 아닌 텍스트 파일로 판단, CSV 방식으로 처리")
            return try parseAsCSV(data: data, filename: url.lastPathComponent)
        }
    }
    
    /// CSV 파일 처리
    private static func parseCSVFile(at url: URL) throws -> [ExcelStockData] {
        print("📊 CSV 파일 처리 시작")
        
        let data = try Data(contentsOf: url)
        return try parseAsCSV(data: data, filename: url.lastPathComponent)
    }
    
    /// 알 수 없는 파일 처리
    private static func parseUnknownFile(at url: URL) throws -> [ExcelStockData] {
        print("📊 알 수 없는 파일 형식, 자동 감지 시작")
        
        let data = try Data(contentsOf: url)
        
        // 파일 타입 자동 감지
        if isZipFile(data: data) {
            print("🔍 ZIP 기반 파일 감지 (XLSX 가능성)")
            throw XLSXError.needsCSVConversion
        } else if isXLSFile(data: data) {
            print("🔍 XLS 바이너리 파일 감지")
            throw XLSXError.needsCSVConversion
        } else {
            print("🔍 텍스트 기반 파일로 판단")
            return try parseAsCSV(data: data, filename: url.lastPathComponent)
        }
    }
    
    /// ZIP 파일 여부 확인 (XLSX 감지용)
    private static func isZipFile(data: Data) -> Bool {
        guard data.count >= 4 else { return false }
        
        let zipSignatures: [[UInt8]] = [
            [0x50, 0x4B, 0x03, 0x04], // PK.. (일반 ZIP)
            [0x50, 0x4B, 0x05, 0x06], // PK.. (빈 ZIP)
            [0x50, 0x4B, 0x07, 0x08]  // PK.. (스팬 ZIP)
        ]
        
        let header = Array(data.prefix(4))
        return zipSignatures.contains(header)
    }
    
    /// XLS 파일 여부 확인
    private static func isXLSFile(data: Data) -> Bool {
        guard data.count >= 8 else { return false }
        
        let xlsSignatures: [[UInt8]] = [
            [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1], // OLE2 (XLS)
            [0x09, 0x08, 0x06, 0x00, 0x00, 0x00, 0x10, 0x00], // BIFF5
            [0x09, 0x08, 0x08, 0x00, 0x00, 0x00, 0x10, 0x00]  // BIFF8
        ]
        
        let header = Array(data.prefix(8))
        return xlsSignatures.contains { signature in
            signature.indices.allSatisfy { header[$0] == signature[$0] }
        }
    }
    
    /// 데이터를 CSV로 파싱
    private static func parseAsCSV(data: Data, filename: String) throws -> [ExcelStockData] {
        print("📝 CSV 방식으로 데이터 파싱")
        
        let content = try decodeTextData(data, filename: filename)
        
        print("📄 디코딩된 내용 길이: \(content.count) 문자")
        print("🔍 첫 200자 미리보기:")
        print(String(content.prefix(200)))
        
        // 텍스트 데이터 유효성 확인
        guard isValidTextData(content) else {
            print("❌ 유효하지 않은 텍스트 데이터")
            throw XLSXError.invalidTextData
        }
        
        return try parseTextContent(content)
    }
    
    /// 텍스트 데이터 디코딩 (다양한 인코딩 시도)
    private static func decodeTextData(_ data: Data, filename: String) throws -> String {
        print("🔤 텍스트 디코딩 시작...")
        
        // 1. BOM 확인
        if let bomResult = detectBOM(data: data) {
            print("✅ BOM 감지: \(bomResult.encoding)")
            return bomResult.content
        }
        
        // 2. 일반적인 인코딩들 시도
        let encodings: [(String.Encoding, String)] = [
            (.utf8, "UTF-8"),
            (.utf16, "UTF-16"),
            (.utf16LittleEndian, "UTF-16 LE"),
            (.utf16BigEndian, "UTF-16 BE"),
            (.isoLatin1, "ISO Latin-1"),
            (.ascii, "ASCII")
        ]
        
        for (encoding, name) in encodings {
            if let content = String(data: data, encoding: encoding) {
                if isValidTextContent(content) {
                    print("✅ \(name) 인코딩으로 성공")
                    return content
                } else {
                    print("⚠️ \(name)로 읽었지만 유효하지 않음")
                }
            }
        }
        
        // 3. 최종 fallback
        print("⚠️ 모든 인코딩 실패, fallback 사용")
        
        if let utf8Content = String(data: data, encoding: .utf8) {
            return utf8Content
        } else {
            // 바이트를 ASCII 범위로 필터링
            let filteredData = data.filter { $0 >= 32 && $0 <= 126 || $0 == 10 || $0 == 13 }
            return String(data: Data(filteredData), encoding: .ascii) ?? "파일을 읽을 수 없습니다"
        }
    }
    
    /// BOM 감지
    private static func detectBOM(data: Data) -> (content: String, encoding: String)? {
        if data.count >= 3 {
            let bom3 = Array(data.prefix(3))
            if bom3 == [0xEF, 0xBB, 0xBF] {
                let withoutBOM = data.dropFirst(3)
                if let content = String(data: withoutBOM, encoding: .utf8) {
                    return (content, "UTF-8 (BOM)")
                }
            }
        }
        
        if data.count >= 2 {
            let bom2 = Array(data.prefix(2))
            if bom2 == [0xFF, 0xFE] {
                if let content = String(data: data, encoding: .utf16LittleEndian) {
                    return (content, "UTF-16 LE (BOM)")
                }
            } else if bom2 == [0xFE, 0xFF] {
                if let content = String(data: data, encoding: .utf16BigEndian) {
                    return (content, "UTF-16 BE (BOM)")
                }
            }
        }
        
        return nil
    }
    
    /// 텍스트 내용 유효성 검사
    private static func isValidTextContent(_ content: String) -> Bool {
        // 너무 짧으면 무효
        guard content.count > 5 else { return false }
        
        // 깨진 문자가 너무 많으면 무효
        let brokenCharCount = content.filter { $0 == "�" }.count
        if brokenCharCount > content.count / 10 { return false }
        
        // 일반적인 데이터 패턴 확인
        let hasStructure = content.contains(",") ||
                          content.contains("\t") ||
                          content.contains("\n") ||
                          content.range(of: "[가-힣]", options: .regularExpression) != nil ||
                          content.range(of: "[a-zA-Z]", options: .regularExpression) != nil
        
        return hasStructure
    }
    
    /// 데이터 유효성 검사
    private static func isValidTextData(_ content: String) -> Bool {
        // 최소 길이 확인
        guard content.count > 10 else { return false }
        
        // 인쇄 가능한 문자 비율 확인
        let printableChars = content.filter { char in
            let scalar = char.unicodeScalars.first?.value ?? 0
            return scalar >= 32 && scalar <= 126 || char == "\n" || char == "\t" || char == "\r"
        }
        
        let printableRatio = Double(printableChars.count) / Double(content.count)
        return printableRatio > 0.3 // 30% 이상이 인쇄 가능한 문자여야 함
    }
    
    /// 텍스트 내용 파싱
    private static func parseTextContent(_ content: String) throws -> [ExcelStockData] {
        // 줄바꿈 정규화
        let normalizedContent = content.replacingOccurrences(of: "\r\n", with: "\n")
                                      .replacingOccurrences(of: "\r", with: "\n")
        
        let lines = normalizedContent.components(separatedBy: "\n")
                                   .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                   .filter { !$0.isEmpty }
        
        print("📋 총 라인 수: \(lines.count)")
        
        guard lines.count > 1 else {
            throw ExcelParsingError.invalidFormat
        }
        
        // 헤더 스킵 여부 결정
        var dataLines = lines
        if lines.count > 1 && isHeaderLine(lines[0]) {
            dataLines = Array(lines.dropFirst())
            print("📌 헤더 스킵: \(lines[0])")
        }
        
        print("📊 데이터 라인 수: \(dataLines.count)")
        
        var stocks: [ExcelStockData] = []
        
        for (index, line) in dataLines.enumerated() {
            let lineNumber = index + 1
            
            do {
                if let stock = try parseStockLine(line, lineNumber: lineNumber) {
                    stocks.append(stock)
                    print("✅ 라인 \(lineNumber): \(stock.companyName)")
                }
            } catch {
                print("❌ 라인 \(lineNumber) 파싱 실패")
                print("   내용: \(String(line.prefix(100)))")
            }
        }
        
        print("🎉 총 \(stocks.count)개 종목 파싱 완료")
        
        guard !stocks.isEmpty else {
            throw ExcelParsingError.invalidFormat
        }
        
        return stocks
    }
    
    /// 헤더 라인 확인
    private static func isHeaderLine(_ line: String) -> Bool {
        let headerKeywords = ["SEQ", "seq", "순번", "회사", "종목", "현재가", "Company", "Stock", "Symbol", "Price"]
        return headerKeywords.contains { line.localizedCaseInsensitiveContains($0) }
    }
    
    /// 안전한 정수 파싱
    private static func safeParseInt(_ string: String?) -> Int? {
        guard let cleaned = cleanString(string) else { return nil }
        
        let numberString = cleaned.replacingOccurrences(of: ",", with: "")
                                 .replacingOccurrences(of: "원", with: "")
                                 .replacingOccurrences(of: " ", with: "")
        
        return Int(numberString)
    }
    
}

// MARK: - XLSX 전용 에러
enum XLSXError: LocalizedError {
    case needsCSVConversion
    case invalidTextData
    
    var errorDescription: String? {
        switch self {
        case .needsCSVConversion:
            return "Excel 파일 형식이 감지되었습니다"
        case .invalidTextData:
            return "텍스트 데이터가 유효하지 않습니다"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .needsCSVConversion:
            return """
            Excel에서 다음과 같이 CSV로 저장해주세요:
            
            1. Excel에서 파일 열기
            2. '파일' → '다른 이름으로 저장'
            3. 파일 형식: 'CSV(쉼표로 구분)(*.csv)' 선택
            4. 저장 후 CSV 파일을 다시 업로드
            
            또는 Google Sheets에서:
            1. 파일 → 다운로드 → CSV(.csv) 선택
            """
        case .invalidTextData:
            return "파일이 손상되었거나 지원하지 않는 형식입니다. CSV 파일로 다시 저장해주세요."
        }
    }
}
