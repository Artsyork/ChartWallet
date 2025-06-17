//
//  ExcelParsingService.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import Foundation

final class ExcelParsingService {
    
    /// 엑셀 파일을 파싱하여 ExcelStockData 배열로 변환
    static func parseExcelFile(at url: URL) throws -> [ExcelStockData] {
        // 파일 확장자 확인
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "csv":
            return try parseCSVFile(at: url)
        case "xlsx", "xls":
            return try parseXLSXFile(at: url)
        default:
            throw ExcelParsingError.invalidFormat
        }
    }
    
    /// XLSX 파일 파싱 (실제 구현)
    private static func parseXLSXFile(at url: URL) throws -> [ExcelStockData] {
        // 여기서 실제 SheetJS나 다른 라이브러리를 사용하여 엑셀 파싱
        // analysis tool에서 구현할 수 있는 JavaScript 코드 예시:
        /*
         import * as XLSX from 'xlsx';
         
         const data = await window.fs.readFile(url.path);
         const workbook = XLSX.read(data, {
         cellStyles: true,
         cellFormulas: true,
         cellDates: true
         });
         
         const worksheet = workbook.Sheets[workbook.SheetNames[0]];
         const jsonData = XLSX.utils.sheet_to_json(worksheet, { header: 1 });
         */
        
        // 현재는 CSV 파싱으로 대체
        throw ExcelParsingError.noWorksheet
    }
    
    /// CSV 파일 파싱 (대안)
    static func parseCSVFile(at url: URL) throws -> [ExcelStockData] {
        let content = try String(contentsOf: url, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)
        
        guard lines.count > 1 else {
            throw ExcelParsingError.invalidFormat
        }
        
        var stocks: [ExcelStockData] = []
        
        // 헤더 건너뛰고 데이터 파싱
        for (index, line) in lines.dropFirst().enumerated() {
            guard !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
            
            let columns = parseCSVLine(line)
            guard columns.count >= 12 else { continue }
            
            let stock = ExcelStockData(
                seq: Int(columns[0]) ?? index + 1,
                companyName: columns[1].trimmingCharacters(in: .whitespacesAndNewlines),
                currentPriceKRW: parseDouble(columns[2]),
                currentPriceUSD: parseDouble(columns[3]),
                sector: columns[4].isEmpty ? nil : columns[4].trimmingCharacters(in: .whitespacesAndNewlines),
                industry: columns[5].isEmpty ? nil : columns[5].trimmingCharacters(in: .whitespacesAndNewlines),
                analystRating: columns[6].isEmpty ? nil : columns[6].trimmingCharacters(in: .whitespacesAndNewlines),
                analystTargetPrice: parseDouble(columns[7]),
                expectedReturn: parseDouble(columns[8]),
                week52High: parseDouble(columns[9]),
                week52Low: parseDouble(columns[10]),
                allTimeHigh: parseDouble(columns[11])
            )
            
            stocks.append(stock)
        }
        
        return stocks
    }
    
    /// CSV 라인 파싱 (쉼표와 따옴표 처리)
    private static func parseCSVLine(_ line: String) -> [String] {
        var columns: [String] = []
        var currentColumn = ""
        var insideQuotes = false
        var i = line.startIndex
        
        while i < line.endIndex {
            let char = line[i]
            
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                columns.append(currentColumn)
                currentColumn = ""
            } else {
                currentColumn.append(char)
            }
            
            i = line.index(after: i)
        }
        
        columns.append(currentColumn) // 마지막 컬럼 추가
        return columns
    }
    
    /// 문자열을 Double로 안전하게 변환
    private static func parseDouble(_ string: String) -> Double? {
        let cleanString = string.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "%", with: "")
        return Double(cleanString)
    }
    
}
