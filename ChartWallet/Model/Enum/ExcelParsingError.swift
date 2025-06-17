//
//  ExcelParsingError.swift
//  ChartWallet
//
//  Created by DY on 6/17/25.
//

import Foundation

enum ExcelParsingError: LocalizedError {
    case invalidFormat
    case noWorksheet
    case corruptedFile
    case unsupportedFileType
    case fileNotFound
    case permissionDenied
    case emptyFile
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "파일 형식이 올바르지 않습니다. CSV 형태의 데이터가 필요합니다."
        case .noWorksheet:
            return "워크시트를 찾을 수 없습니다."
        case .corruptedFile:
            return "파일이 손상되었습니다."
        case .unsupportedFileType:
            return "지원하지 않는 파일 형식입니다. CSV 파일을 사용해주세요."
        case .fileNotFound:
            return "파일을 찾을 수 없습니다."
        case .permissionDenied:
            return "파일 접근 권한이 없습니다."
        case .emptyFile:
            return "빈 파일입니다."
        case .encodingError:
            return "파일 인코딩을 읽을 수 없습니다."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidFormat:
            return "Excel 파일을 CSV 형식으로 저장한 후 다시 시도해주세요."
        case .unsupportedFileType:
            return "Excel에서 '다른 이름으로 저장' → 'CSV(쉼표로 구분)'을 선택해주세요."
        case .encodingError:
            return "파일을 UTF-8 인코딩으로 저장해주세요."
        default:
            return "파일을 다시 확인하고 재시도해주세요."
        }
    }
}
