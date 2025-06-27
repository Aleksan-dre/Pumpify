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
}
