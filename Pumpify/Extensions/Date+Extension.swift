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

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)!
    }
}

// MARK: - Date Related Models
struct YearAndWeek: Hashable, Comparable {
    let weekOfYear: Int
    let month: Int
    let year: Int
    
    /// Calculate the start date of the week
    var startDate: Date {
        var components = DateComponents()
        components.weekOfYear = weekOfYear
        components.month = month
        components.yearForWeekOfYear = year
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var longString: String {
        "\(monthName(from: month)) - Week \(weekOfYear), \(year)"
    }
    
    static func < (lhs: YearAndWeek, rhs: YearAndWeek) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        } else if lhs.month != rhs.month {
            return lhs.month < rhs.month
        }
        return lhs.weekOfYear < rhs.weekOfYear
    }
}

func monthName(from month: Int) -> String {
    let dateFormatter = DateFormatter()
    let months = dateFormatter.monthSymbols
    guard month >= 1, month <= 12, let months = months else {
        return "Invalid month"
    }
    return months[month - 1] /// Array is zero-indexed, months are 1-indexed
}

struct MonthAndYear: Codable, Identifiable, Comparable, Hashable {
    static func < (lhs: MonthAndYear, rhs: MonthAndYear) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        }
        return lhs.month < rhs.month
    }
    
    var month: Int
    var year: Int
    
    var id: Int64 { Int64(month) + Int64(year) * 12 }
    
    var date: Date {
        Calendar.current.date(from: DateComponents(
            year: year,
            month: month
        ))!
    }
    
    init(from date: Date) {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        self.year = components.year ?? 0
        self.month = components.month ?? 0
    }
    
    var longString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return dateFormatter.string(from: self.date)
    }
}
