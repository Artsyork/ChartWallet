//
//  String+.swift
//  ChartWallet
//
//  Created by DY on 6/23/25.
//

import Foundation

extension String {
     
    func getFormattedMoney() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        // 문자열을 숫자로 변환 후 다시 포맷팅
        if let number = Int(self) {
            return formatter.string(from: NSNumber(value: number)) ?? self
        }
        return self
    }
    
}
