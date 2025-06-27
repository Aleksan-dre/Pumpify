//
//  TimeInterval+Extension.swift
//  Pumpify
//
//  Created by TimurSmoev on 6/27/25.
//

import Foundation

import Foundation

extension TimeInterval {
    func formattedTime() -> String {
        let totalSeconds = Int(self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        var components: [String] = []
        if hours > 0 { components.append("\(hours)h") }
        if minutes > 0 { components.append("\(minutes)m") }
        if seconds > 0 || components.isEmpty { components.append("\(seconds)s") }
        
        return components.joined(separator: " ")
    }
}
