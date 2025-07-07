//
//  DayOfWeek.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 27.06.25.
//

import Foundation

enum DayOfWeek: Int, Codable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    static let all: [DayOfWeek] = [
        .monday,
        .tuesday,
        .wednesday,
        .thursday,
        .friday,
        .saturday,
        .sunday,
    ]
}

extension DayOfWeek: Identifiable {
    var id: Int { self.rawValue }
}

extension DayOfWeek {
    var string : String {
        switch self {
        case .monday: "Monday"
        case .tuesday: "Tuesday"
        case .wednesday: "Wednesday"
        case .thursday: "Thursday"
        case .friday: "Friday"
        case .saturday: "Saturday"
        case .sunday: "Sunday"
        }
    }
    var shortString : String {
        let longString = self.string
        // Take only the first 3 letters from self.string
        // For example: Monday -> Mon; Tuesday -> Tue
        return String(longString[longString.startIndex..<longString.index(longString.startIndex, offsetBy: 3)])
    }
    
    static func from(date: Date) -> DayOfWeek {
        let weekday = Calendar.current.component(.weekday, from: date)
        // Convert Sunday = 1, Monday = 2... to Monday = 1, Tuesday = 2...
        let adjustedWeekday = weekday == 1 ? 7 : weekday - 1
        return DayOfWeek(rawValue: adjustedWeekday) ?? .monday
    }
}
