//
//  StopwatchData.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 27.06.25.
//

import SwiftUI
import SwiftData

@Model
class StopwatchData {
    var completionDate: Date
    var times: [Time]
    var exerciseId: UUID

    init(
        completionDate: Date,
        exerciseId: UUID,
        times: [Time]
    ) {
        self.completionDate = completionDate
        self.exerciseId = exerciseId
        self.times = times
    }
    
    var totalInterval: TimeInterval {
        times.lazy.map { $0.interval }.reduce(.zero, +)
    }

}

@Model
class Time {
    var start: Date
    var end: Date
    
    init(start: Date, end: Date) {
        self.start = start
        self.end = end

    }
    
    var interval: TimeInterval {
        start.distance(to: end)
    }
}
