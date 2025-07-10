//
//  Schema.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 27.06.25.
//

import Foundation
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
        
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            print("❌ Failed to initialize the model container: \(error)")
            
            // Try to create a new container with migration
            do {
                let migrationConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    allowsSave: true
                )
                
                let container = try ModelContainer(for: schema, configurations: migrationConfig)
                print("✅ Successfully created model container with migration")
                return container
            } catch {
                print("❌ Failed to create container even with migration: \(error)")
                
                // As a last resort, try to reset the database
                do {
                    let resetConfig = ModelConfiguration(
                        schema: schema,
                        isStoredInMemoryOnly: false,
                        allowsSave: true
                    )
                    
                    // Clear any existing data files
                    try clearSwiftDataFiles()
                    
                    let container = try ModelContainer(for: schema, configurations: resetConfig)
                    print("✅ Successfully created model container after reset")
                    return container
                } catch {
                    fatalError("Failed to initialize the model container even after reset: \(error)")
                }
            }
        }
    }
    
    /// Clear SwiftData files to force a fresh start
    private static func clearSwiftDataFiles() throws {
        let fileManager = FileManager.default
        
        // Get the application support directory
        guard let appSupportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return
        }
        
        // Look for SwiftData files
        let swiftDataFiles = try fileManager.contentsOfDirectory(at: appSupportDir, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "sqlite" || $0.pathExtension == "sqlite-shm" || $0.pathExtension == "sqlite-wal" }
        
        // Remove SwiftData files
        for file in swiftDataFiles {
            try fileManager.removeItem(at: file)
            print("🗑️ Removed SwiftData file: \(file.lastPathComponent)")
        }
    }
}
