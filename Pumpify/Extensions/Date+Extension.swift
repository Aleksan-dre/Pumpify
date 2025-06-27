//
//  Date+Extension.swift
//  Pumpify
//
//  Created by TimurSmoev on 6/27/25.
//

import Foundation

extension Date {
    func withoutSeconds() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        components.second = .zero
        let date = Calendar.current.date(from: components)!
        return date
    }
}
