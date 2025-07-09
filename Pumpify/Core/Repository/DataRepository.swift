//
//  DataRepository.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 06.07.25.
//

import Foundation
import SwiftData
import FirebaseAuth
import Combine

@MainActor
final class DataRepository: ObservableObject, DataRepositoryProtocol {
    let modelContext: ModelContext
    private let firebaseService = FirebaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var syncStatus: SyncStatus = .idle
    @Published var syncError: Error?
    
    // Track sync state for current user
    private var lastSyncedUserId: String?
    private var hasSyncedForCurrentUser: Bool = false
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        setupUserSwitchListener()
    }
    
    private func setupUserSwitchListener() {
        NotificationCenter.default.addObserver(
            forName: .userDidSwitch,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.handleUserSwitch()
            }
        }
    }
    
    /// Clear all local data and sync from Firebase when user switches
    private func handleUserSwitch() async {
        do {
            // Clear all local data first
            await clearAllLocalData()
            
            // Reset sync state for new user
            lastSyncedUserId = nil
            hasSyncedForCurrentUser = false
            
            // If user is authenticated, sync fresh data from Firebase
            if let currentUserId = Auth.auth().currentUser?.uid {
                print("🔄 Syncing fresh data after user switch...")
                try await syncAllData()
                lastSyncedUserId = currentUserId
                hasSyncedForCurrentUser = true
                print("✅ User switch completed with fresh data sync")
            }
        } catch {
            print("❌ Failed to sync data after user switch: \(error)")
        }
    }
    
    /// Clear all local data when user switches
    private func clearAllLocalData() async {
        do {
            // Clear all workouts
            let workoutDescriptor = FetchDescriptor<Workout>()
            let workouts = try modelContext.fetch(workoutDescriptor)
            for workout in workouts {
                modelContext.delete(workout)
            }
            
            // Clear all exercises
            let exerciseDescriptor = FetchDescriptor<Exercise>()
            let exercises = try modelContext.fetch(exerciseDescriptor)
            for exercise in exercises {
                modelContext.delete(exercise)
            }
            
            // Clear all settings
            let settingsDescriptor = FetchDescriptor<Settings>()
            let settings = try modelContext.fetch(settingsDescriptor)
            for setting in settings {
                modelContext.delete(setting)
            }
            
            // Clear all stopwatch data
            let stopwatchDescriptor = FetchDescriptor<StopwatchData>()
            let stopwatchData = try modelContext.fetch(stopwatchDescriptor)
            for data in stopwatchData {
                modelContext.delete(data)
            }
            
            try modelContext.save()
            print("✅ Cleared all local data for user switch")
        } catch {
            print("❌ Failed to clear local data: \(error)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .userDidSwitch, object: nil)
    }
    
    // MARK: - Workout Operations
    
    func saveWorkout(_ workout: Workout) async throws {
        // Save to local database first
        modelContext.insert(workout)
        try modelContext.save()
        
        // Sync to Firebase if user is authenticated
        if let userId = Auth.auth().currentUser?.uid {
            syncStatus = .syncing
            do {
                let firebaseWorkout = FirebaseWorkout.fromSwiftData(workout, userId: userId)
                _ = try await firebaseService.save(firebaseWorkout, to: "workouts", documentId: workout.id.uuidString)
                syncStatus = .synced
            } catch {
                syncStatus = .error
                syncError = error
                print("Failed to sync workout to Firebase: \(error)")
            }
        }
    }
    
    func updateWorkout(_ workout: Workout) async throws {
        try modelContext.save()
        
        if let userId = Auth.auth().currentUser?.uid {
            syncStatus = .syncing
            do {
                let firebaseWorkout = FirebaseWorkout.fromSwiftData(workout, userId: userId)
                _ = try await firebaseService.save(firebaseWorkout, to: "workouts", documentId: workout.id.uuidString)
                syncStatus = .synced
            } catch {
                syncStatus = .error
                syncError = error
                print("Failed to update workout in Firebase: \(error)")
            }
        }
    }
    
    func deleteWorkout(_ workout: Workout) async throws {
        // Delete from local database first
        modelContext.delete(workout)
        try modelContext.save()
        
        // Delete from Firebase
        if Auth.auth().currentUser != nil {
            syncStatus = .syncing
            do {
                try await firebaseService.delete(from: "workouts", documentId: workout.id.uuidString)
                syncStatus = .synced
            } catch {
                syncStatus = .error
                syncError = error
                print("Failed to delete workout from Firebase: \(error)")
            }
        }
    }
    
    func fetchWorkouts() async throws -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(
            sortBy: [
                SortDescriptor(\Workout.priority, order: .reverse),
                SortDescriptor(\Workout.name)
            ]
        )
        
        // Check if we need to sync data for the current user
        if let currentUserId = Auth.auth().currentUser?.uid {
            // Only sync if we haven't synced for this user yet, or if user has changed
            if !hasSyncedForCurrentUser || lastSyncedUserId != currentUserId {
                print("🔄 Syncing workouts for user: \(currentUserId)")
                syncStatus = .syncing
                
                do {
                    // First clear all local data - this ensures no partial deletions
                    try clearLocalData() 
                    
                    // Fetch fresh data from Firebase
                    let firebaseWorkouts = try await firebaseService.fetchAll(FirebaseWorkout.self, from: "workouts")
                    
                    // Map the Firebase workouts to a dictionary by ID for quick lookup
                    // to prevent any possible duplicates
                    var workoutMap = [String: FirebaseWorkout]()
                    for workout in firebaseWorkouts {
                        workoutMap[workout.id] = workout
                    }
                    
                    // Insert unique Firebase data into local storage
                    for firebaseWorkout in workoutMap.values {
                        let newWorkout = firebaseWorkout.toSwiftData()
                        modelContext.insert(newWorkout)
                    }
                    
                    try modelContext.save()
                    
                    // Check for and remove any duplicates that might have been created
                    try checkAndRemoveDuplicates()
                    
                    syncStatus = .synced
                    
                    // Mark as synced for current user
                    lastSyncedUserId = currentUserId
                    hasSyncedForCurrentUser = true
                    
                    print("✅ Workouts synced successfully for user: \(currentUserId)")
                } catch {
                    syncStatus = .error
                    syncError = error
                    print("❌ Failed to sync workouts from Firebase: \(error)")
                    // Return empty array on error to prevent showing stale data
                    return []
                }
            }
        }
        
        // Return local data (either freshly synced or existing)
        return try modelContext.fetch(descriptor)
    }
    
    func fetchWorkout(by id: UUID) async throws -> Workout? {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    func searchWorkouts(term: String) async throws -> [SearchResult] {
        let descriptor = FetchDescriptor<Workout>(
            sortBy: [
                SortDescriptor(\Workout.priority, order: .reverse),
                SortDescriptor(\Workout.name)
            ]
        )
        let workouts = try modelContext.fetch(descriptor)
        return searchInWorkouts(workouts, term: term)
    }
    
    private func searchInWorkouts(_ workouts: [Workout], term: String) -> [SearchResult] {
        guard !term.isEmpty else { return [] }
        
        let searchTerm = term.lowercased()
        var result: [Workout: SearchResult] = [:]
        
        for workout in workouts {
            if workout.name.lowercased().contains(searchTerm) {
                result[workout] = SearchResult(
                    workout: workout,
                    exercises: [],
                    tags: [],
                    findReasons: [.workout]
                )
            }
            
            for exercise in workout.exercises {
                if exercise.name.lowercased().contains(searchTerm) {
                    var sr = result[workout] ?? SearchResult(
                        workout: workout,
                        exercises: [],
                        tags: [],
                        findReasons: []
                    )
                    sr.exercises.insert(exercise)
                    sr.findReasons.insert(.exercise(exercise.id))
                    result[workout] = sr
                }
                
                for tag in exercise.tags where tag.lowercased().contains(searchTerm) {
                    var sr = result[workout] ?? SearchResult(
                        workout: workout,
                        exercises: [],
                        tags: [],
                        findReasons: []
                    )
                    sr.exercises.insert(exercise)
                    sr.tags.insert(tag)
                    sr.findReasons.insert(.tag(tag))
                    result[workout] = sr
                }
            }
        }
        
        return Array(result.values)
    }
    
    // MARK: - Exercise Operations
    
    func fetchExercises(for workout: Workout) async throws -> [Exercise] {
        return workout.exercises
    }
    
    func fetchExercise(by id: UUID) async throws -> Exercise? {
        let descriptor = FetchDescriptor<Workout>()
        let workouts = try modelContext.fetch(descriptor)
        return workouts.flatMap { $0.exercises }.first { $0.id == id }
    }
    
    func fetchExercisesForDate(_ date: Date) async throws -> [Exercise] {
        let descriptor = FetchDescriptor<Workout>()
        let workouts = try modelContext.fetch(descriptor)
        let allExercises = workouts.flatMap { $0.exercises }
        
        let componentsOfDate = Calendar.current.dateComponents([.day, .month, .year], from: date)
        return allExercises.filter { exercise in
            if exercise.startDate > Calendar.current.date(byAdding: .day, value: 1, to: date)! {
                return false
            }
            
            let componentsOfExercise = Calendar.current.dateComponents([.day, .month, .year], from: exercise.startDate)
            if componentsOfDate == componentsOfExercise {
                return true
            }
            
            var weekdayOfDate = (Calendar.current.dateComponents([.weekday], from: date).weekday! + 6) % 7
            if weekdayOfDate == 0 { weekdayOfDate = 7 }
            let weekday = DayOfWeek(rawValue: weekdayOfDate)!
            return exercise.repeatDays.contains(weekday)
        }
    }
    
    // MARK: - Stopwatch Data Operations
    
    func fetchStopwatchData(for exerciseId: UUID, on date: Date) async throws -> StopwatchData? {
        let descriptor = FetchDescriptor<StopwatchData>()
        let stopwatchData = try modelContext.fetch(descriptor)
        
        return stopwatchData.first { data in
            data.exerciseId == exerciseId && Calendar.current.isDate(data.completionDate, inSameDayAs: date)
        }
    }
    
    func fetchAllStopwatchData() async throws -> [StopwatchData] {
        let descriptor = FetchDescriptor<StopwatchData>()
        return try modelContext.fetch(descriptor)
    }
    
    func deleteStopwatchData(_ stopwatchData: StopwatchData) async throws {
        modelContext.delete(stopwatchData)
        try modelContext.save()
        
        if Auth.auth().currentUser != nil {
            syncStatus = .syncing
            do {
                // Note: We need to store the Firebase document ID for proper deletion
                // This is a limitation of the current implementation
                syncStatus = .synced
            } catch {
                syncStatus = .error
                syncError = error
                print("Failed to delete stopwatch data from Firebase: \(error)")
            }
        }
    }
    
    // MARK: - Settings Operations
    
    func fetchSettings() async throws -> Settings? {
        let descriptor = FetchDescriptor<Settings>()
        let settings = try modelContext.fetch(descriptor)
        return settings.first ?? {
            let newSettings = Settings()
            modelContext.insert(newSettings)
            try? modelContext.save()
            return newSettings
        }()
    }
    
    func updateSettings(_ settings: Settings) async throws {
        try modelContext.save()
        
        if let userId = Auth.auth().currentUser?.uid {
            syncStatus = .syncing
            do {
                let firebaseSettings = FirebaseSettings.fromSwiftData(settings, userId: userId)
                _ = try await firebaseService.save(firebaseSettings, to: "settings", documentId: "user_settings")
                syncStatus = .synced
            } catch {
                syncStatus = .error
                syncError = error
                print("Failed to update settings in Firebase: \(error)")
            }
        }
    }
    
    // MARK: - Exercise Operations (continued from original)
    
    func saveExercise(_ exercise: Exercise, to workout: Workout) async throws {
        workout.exercises.append(exercise)
        try modelContext.save()
        
        if let userId = Auth.auth().currentUser?.uid {
            syncStatus = .syncing
            do {
                let firebaseExercise = FirebaseExercise.fromSwiftData(exercise, workoutId: workout.id.uuidString, userId: userId)
                _ = try await firebaseService.save(firebaseExercise, to: "exercises", documentId: exercise.id.uuidString)
                
                // Update the workout in Firebase as well
                let firebaseWorkout = FirebaseWorkout.fromSwiftData(workout, userId: userId)
                _ = try await firebaseService.save(firebaseWorkout, to: "workouts", documentId: workout.id.uuidString)
                
                syncStatus = .synced
            } catch {
                syncStatus = .error
                syncError = error
                print("Failed to sync exercise to Firebase: \(error)")
            }
        }
    }
    
    func updateExercise(_ exercise: Exercise, in workout: Workout) async throws {
        try modelContext.save()
        
        if let userId = Auth.auth().currentUser?.uid {
            syncStatus = .syncing
            do {
                let firebaseExercise = FirebaseExercise.fromSwiftData(exercise, workoutId: workout.id.uuidString, userId: userId)
                _ = try await firebaseService.save(firebaseExercise, to: "exercises", documentId: exercise.id.uuidString)
                
                // Update the workout in Firebase as well
                let firebaseWorkout = FirebaseWorkout.fromSwiftData(workout, userId: userId)
                _ = try await firebaseService.save(firebaseWorkout, to: "workouts", documentId: workout.id.uuidString)
                
                syncStatus = .synced
            } catch {
                syncStatus = .error
                syncError = error
                print("Failed to update exercise in Firebase: \(error)")
            }
        }
    }
    
    func deleteExercise(_ exercise: Exercise, from workout: Workout) async throws {
        // Remove from workout's exercises array
        workout.exercises.removeAll { $0.id == exercise.id }
        
        // Delete the exercise
        modelContext.delete(exercise)
        try modelContext.save()
        
        if Auth.auth().currentUser != nil {
            syncStatus = .syncing
            do {
                try await firebaseService.delete(from: "exercises", documentId: exercise.id.uuidString)
                syncStatus = .synced
            } catch {
                syncStatus = .error
                syncError = error
                print("Failed to delete exercise from Firebase: \(error)")
            }
        }
    }
    
    // MARK: - Stopwatch Data Operations
    
    func saveStopwatchData(_ stopwatchData: StopwatchData) async throws {
        modelContext.insert(stopwatchData)
        try modelContext.save()
        
        if let userId = Auth.auth().currentUser?.uid {
            syncStatus = .syncing
            do {
                let firebaseStopwatchData = FirebaseStopwatchData.fromSwiftData(stopwatchData, userId: userId)
                _ = try await firebaseService.save(firebaseStopwatchData, to: "stopwatch_data", documentId: UUID().uuidString)
                syncStatus = .synced
            } catch {
                syncStatus = .error
                syncError = error
                print("Failed to sync stopwatch data to Firebase: \(error)")
            }
        }
    }
    
    func updateStopwatchData(_ stopwatchData: StopwatchData) async throws {
        try modelContext.save()
        
        if let userId = Auth.auth().currentUser?.uid {
            syncStatus = .syncing
            do {
                let firebaseStopwatchData = FirebaseStopwatchData.fromSwiftData(stopwatchData, userId: userId)
                _ = try await firebaseService.save(firebaseStopwatchData, to: "stopwatch_data", documentId: UUID().uuidString)
                syncStatus = .synced
            } catch {
                syncStatus = .error
                syncError = error
                print("Failed to update stopwatch data in Firebase: \(error)")
            }
        }
    }
    
    // MARK: - Settings Operations
    
    func saveSettings(_ settings: Settings) async throws {
        try modelContext.save()
        
        if let userId = Auth.auth().currentUser?.uid {
            syncStatus = .syncing
            do {
                let firebaseSettings = FirebaseSettings.fromSwiftData(settings, userId: userId)
                _ = try await firebaseService.save(firebaseSettings, to: "settings", documentId: "user_settings")
                syncStatus = .synced
            } catch {
                syncStatus = .error
                syncError = error
                print("Failed to sync settings to Firebase: \(error)")
            }
        }
    }
    
    // MARK: - Sync Operations
    
    func syncAllData() async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw DataRepositoryError.userNotAuthenticated
        }
        
        // Prevent duplicate syncing for the same user
        if hasSyncedForCurrentUser && lastSyncedUserId == currentUserId {
            print("✅ Data already synced for current user: \(currentUserId)")
            return
        }
        
        syncStatus = .syncing
        print("🔄 Starting full sync for user: \(currentUserId)")
        
        do {
            // Clear all local data first to prevent data mixing
            try clearLocalData()
            
            // Sync workouts with their exercises (they're embedded)
            let firebaseWorkouts = try await firebaseService.fetchAll(FirebaseWorkout.self, from: "workouts")
            
            // Create a map of workouts by ID to prevent duplicates
            var workoutMap = [String: FirebaseWorkout]()
            for workout in firebaseWorkouts {
                workoutMap[workout.id] = workout
            }
            
            // Insert unique workouts
            for firebaseWorkout in workoutMap.values {
                let newWorkout = firebaseWorkout.toSwiftData()
                modelContext.insert(newWorkout)
            }
            
            // Sync settings - create a map to handle duplicates
            let firebaseSettings = try await firebaseService.fetchAll(FirebaseSettings.self, from: "settings")
            var settingsMap = [String: FirebaseSettings]()
            for setting in firebaseSettings {
                settingsMap[setting.id] = setting
            }
            
            // Insert unique settings
            for setting in settingsMap.values {
                let localSettings = setting.toSwiftData()
                modelContext.insert(localSettings)
            }
            
            // Sync stopwatch data - create a map to handle duplicates
            let firebaseStopwatchData = try await firebaseService.fetchAll(FirebaseStopwatchData.self, from: "stopwatch_data")
            var stopwatchMap = [String: FirebaseStopwatchData]()
            for data in firebaseStopwatchData {
                stopwatchMap[data.id] = data
            }
            
            // Insert unique stopwatch data
            for data in stopwatchMap.values {
                let localStopwatchData = data.toSwiftData()
                modelContext.insert(localStopwatchData)
            }
            
            try modelContext.save()
            
            // Check for and remove any duplicates that might have been created
            try checkAndRemoveDuplicates()
            
            syncStatus = .synced
            
            // Mark as synced for current user
            lastSyncedUserId = currentUserId
            hasSyncedForCurrentUser = true
            
            print("✅ All data synced successfully for user: \(currentUserId)")
        } catch {
            syncStatus = .error
            syncError = error
            print("❌ Failed to sync all data: \(error)")
            throw error
        }
    }
    
    /// Handle initial login to ensure fresh data sync
    func handleInitialLogin() async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw DataRepositoryError.userNotAuthenticated
        }
        
        print("🔑 Handling initial login for user: \(currentUserId)")
        
        // Only sync if we haven't synced for this user yet
        if !hasSyncedForCurrentUser || lastSyncedUserId != currentUserId {
            print("🔄 First login or user change detected - syncing user data...")
            try await syncAllData()
            print("✅ Initial login data sync completed for user: \(currentUserId)")
        } else {
            print("✅ Data already synced for current user: \(currentUserId)")
        }
    }
    
    func clearLocalData() throws {
        print("🧹 Clearing all local data...")
        
        // Clear all workouts (which will also clear exercises due to cascade delete)
        let workouts = try modelContext.fetch(FetchDescriptor<Workout>())
        for workout in workouts {
            modelContext.delete(workout)
        }
        
        // Clear all stopwatch data
        let stopwatchData = try modelContext.fetch(FetchDescriptor<StopwatchData>())
        for data in stopwatchData {
            modelContext.delete(data)
        }
        
        // Clear all settings
        let settings = try modelContext.fetch(FetchDescriptor<Settings>())
        for setting in settings {
            modelContext.delete(setting)
        }
        
        try modelContext.save()
        
        // Force a complete processing of the current transaction
        // This helps ensure deletion is fully complete before inserting new data
        modelContext.processPendingChanges()
        
        print("✅ Local data cleared successfully")
    }
    
    /// Force refresh data from Firebase (for pull-to-refresh)
    func forceRefreshData() async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw DataRepositoryError.userNotAuthenticated
        }
        
        print("🔄 Force refreshing data for user: \(currentUserId)")
        
        // Reset sync state to force fresh sync
        hasSyncedForCurrentUser = false
        lastSyncedUserId = nil
        
        // Perform full sync
        try await syncAllData()
        
        print("✅ Force refresh completed for user: \(currentUserId)")
    }
    
    /// Check for and remove duplicate data that may exist in the local database
    private func checkAndRemoveDuplicates() throws {
        print("🔍 Checking for duplicate data...")
        
        // Check for duplicate workouts (same ID)
        let workoutDescriptor = FetchDescriptor<Workout>()
        let workouts = try modelContext.fetch(workoutDescriptor)
        
        var uniqueWorkoutIds = Set<UUID>()
        var workoutDuplicates = [Workout]()
        
        for workout in workouts {
            if uniqueWorkoutIds.contains(workout.id) {
                // This is a duplicate
                workoutDuplicates.append(workout)
            } else {
                uniqueWorkoutIds.insert(workout.id)
            }
        }
        
        // Remove duplicate workouts
        for duplicate in workoutDuplicates {
            print("🗑️ Removing duplicate workout: \(duplicate.name) (ID: \(duplicate.id))")
            modelContext.delete(duplicate)
        }
        
        // Check for duplicate stopwatch data entries
        let stopwatchDescriptor = FetchDescriptor<StopwatchData>()
        let stopwatchEntries = try modelContext.fetch(stopwatchDescriptor)
        
        var uniqueStopwatchByExerciseAndDate = [String: StopwatchData]()
        var stopwatchDuplicates = [StopwatchData]()
        
        for data in stopwatchEntries {
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: data.completionDate)
            let key = "\(data.exerciseId)_\(dateComponents.year ?? 0)_\(dateComponents.month ?? 0)_\(dateComponents.day ?? 0)"
            
            if uniqueStopwatchByExerciseAndDate[key] != nil {
                // This is a duplicate for the same exercise and day
                stopwatchDuplicates.append(data)
            } else {
                uniqueStopwatchByExerciseAndDate[key] = data
            }
        }
        
        // Remove duplicate stopwatch data
        for duplicate in stopwatchDuplicates {
            print("🗑️ Removing duplicate stopwatch data for exercise: \(duplicate.exerciseId) on date: \(duplicate.completionDate)")
            modelContext.delete(duplicate)
        }
        
        // Save changes if any duplicates were found and removed
        if !workoutDuplicates.isEmpty || !stopwatchDuplicates.isEmpty {
            try modelContext.save()
            print("✅ Removed \(workoutDuplicates.count) duplicate workouts and \(stopwatchDuplicates.count) duplicate stopwatch entries")
        } else {
            print("✅ No duplicates found")
        }
    }
}

// MARK: - Supporting Types
enum SyncStatus {
    case idle
    case syncing
    case synced
    case error
    
    var description: String {
        switch self {
        case .idle:
            return "Not syncing"
        case .syncing:
            return "Syncing..."
        case .synced:
            return "Synced"
        case .error:
            return "Sync error"
        }
    }
}

enum DataRepositoryError: LocalizedError {
    case userNotAuthenticated
    case syncFailed
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "User is not authenticated"
        case .syncFailed:
            return "Failed to sync data"
        }
    }
}
