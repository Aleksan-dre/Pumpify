//
//  ActivityFactory.swift
//  Pumpify
//
//  Created by Timur Smoev on 12.05.25.
//  Home/Factory/ActivityFactory.swift

import Foundation

class StatsFactory {
    static func makeWeeklyStats() -> Stats {
        // Replace with real data fetching or computation
        return Stats(title: "Weekly Progress", progress: 0.7, message: "Keep going, you're doing great!")
    }
}
