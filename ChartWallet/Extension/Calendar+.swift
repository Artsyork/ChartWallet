//
//  Calendar+.swift
//  ChartWallet
//
//  Created by DY on 6/5/25.
//

import Foundation

extension Calendar {
    
    func dateBySettingTime(hour: Int, minute: Int = 0, second: Int = 0, of date: Date = Date()) -> Date? {
        var components = self.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute
        components.second = second
        return self.date(from: components)
    }
    
}
