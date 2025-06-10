//
//  ActivityFactory.swift
//  Pumpify
//
//  Created by Timur Smoev on 12.05.25.
//  Home/Factory/ActivityFactory.swift

import Foundation

class ActivityFactory {
    static func makeRecentActivities() -> [Activity] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let todayString = formatter.string(from: Date())
        return [
            Activity(activityName: "Cycling", date: todayString, duration: "1h", iconName: "bicycle"),
            Activity(activityName: "Swimming", date: todayString, duration: "30m", iconName: "drop.fill")
        ]
    }
}
