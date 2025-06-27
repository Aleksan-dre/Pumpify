//
//  Workout.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 27.06.25.
//

import Foundation
import SwiftData

@Model
class Workout: Identifiable {
    var id: UUID  // Unique identifier for Identifiable protocol
    var name: String
    var tasks: [Exercise]
    var startDate: Date  // Date type
    var priority: Int
    
    init(
        id: UUID = UUID(),
        name: String,
        tasks: [Exercise] = [],
        startDate: Date,
        priority: Int = 2
    ) {
        self.id = id
        self.name = name
        self.tasks = tasks
        self.startDate = startDate
        self.priority = priority
    }
}

@Model
class Exercise: Identifiable {
    var id: UUID  // Unique identifier for Identifiable protocol
    
    var name: String
    var tags: [String]
    var startDate: Date  // Date type
    var priority: Int
    var repeatDays: Set<DayOfWeek>
    
    init(
        id: UUID = UUID(),
        name: String,
        tags: [String] = [],
        startDate: Date,
        priority: Int = 2,
        repeatDays: Set<DayOfWeek> = Set()
    ) {
        self.id = id
        self.name = name
        self.tags = tags
        self.startDate = startDate
        self.priority = priority
        self.repeatDays = repeatDays
    }
}

