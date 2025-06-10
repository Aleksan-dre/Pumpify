//
//  ActivityFactory.swift
//  Pumpify
//
//  Created by Timur Smoev on 12.05.25.
//  Home/Factory/ActivityFactory.swift

import Foundation
import SwiftUI

class RecommendedWorkoutFactory {
    static func makeRecommendedWorkouts() -> [RecommendedWorkout] {
        return [
            RecommendedWorkout(name: "Quick Cardio", duration: "15m", color: .red),
            RecommendedWorkout(name: "Strength Training", duration: "40m", color: .green),
            RecommendedWorkout(name: "Pilates", duration: "30m", color: .purple)
        ]
    }
}

