//
//  Schema.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 27.06.25.
//

import SwiftData

extension ModelContainer {
    /// Initializes and returns a ModelContainer instance, safely handling any potential errors.
    static func initializeModelContainer() -> ModelContainer {
        let schema = Schema([
            Workout.self,
            Exercise.self,
            Settings.self,
            StopwatchData.self,
            Time.self,
            Tag.self
        ])
        
        let config = ModelConfiguration()
        
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to initialize the model container: \(error)")
        }
    }
}
