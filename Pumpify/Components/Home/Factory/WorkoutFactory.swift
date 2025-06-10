//
//  ActivityFactory.swift
//  Pumpify
//
//  Created by Timur Smoev on 12.05.25.
//  Home/Factory/ActivityFactory.swift

import Foundation

class WorkoutFactory {
    static func makeSampleWorkouts() -> [Workout] {
        return [
            Workout(title: "Morning Yoga", duration: "30m", intensity: "Low", iconName: "figure.walk"),
            Workout(title: "HIIT Session", duration: "20m", intensity: "High", iconName: "flame"),
            Workout(title: "Evening Run", duration: "45m", intensity: "Medium", iconName: "figure.run")
        ]
    }
}
