//
//  MockDataRepository.swift
//  PumpifyTests
//
//  Created by Aleksandre Shalikashvili on 11.07.25.
//

import Foundation
import SwiftData
import Combine
@testable import Pumpify

@MainActor
final class MockDataRepository: DataRepositoryProtocol {
    
    // MARK: - Mock Data Storage
    var mockWorkouts: [Workout] = []
    var mockExercises: [Exercise] = []
    var mockStopwatchData: [StopwatchData] = []
    var mockSettings: Settings?
    var mockSearchResults: [SearchResult] = []
    
    // MARK: - Mock State
    var shouldThrowError = false
    var mockError: Error = TestError.mockError
    var forceRefreshCalled = false
    
    // MARK: - Protocol Requirements
    nonisolated let modelContext: ModelContext
    nonisolated var syncStatus: SyncStatus { .synced }
    nonisolated var syncError: Error? { nil }
    
    // MARK: - Published Properties (for ObservableObject)
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    init() {
        // Create a temporary in-memory model context for testing
        let schema = Schema([Workout.self, Exercise.self, Settings.self, StopwatchData.self, Time.self, Tag.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: config)
        self.modelContext = container.mainContext
    }
    
    // MARK: - Workout Operations
    
    func saveWorkout(_ workout: Workout) async throws {
        if shouldThrowError { throw mockError }
        mockWorkouts.append(workout)
    }
    
    func updateWorkout(_ workout: Workout) async throws {
        if shouldThrowError { throw mockError }
        if let index = mockWorkouts.firstIndex(where: { $0.id == workout.id }) {
            mockWorkouts[index] = workout
        }
    }
    
    func deleteWorkout(_ workout: Workout) async throws {
        if shouldThrowError { throw mockError }
        mockWorkouts.removeAll { $0.id == workout.id }
    }
    
    func fetchWorkouts() async throws -> [Workout] {
        if shouldThrowError { throw mockError }
        return mockWorkouts
    }
    
    func fetchWorkout(by id: UUID) async throws -> Workout? {
        if shouldThrowError { throw mockError }
        return mockWorkouts.first { $0.id == id }
    }
    
    func searchWorkouts(term: String) async throws -> [SearchResult] {
        if shouldThrowError { throw mockError }
        return mockSearchResults.filter { result in
            result.workout.name.lowercased().contains(term.lowercased()) ||
            result.exercises.contains { $0.name.lowercased().contains(term.lowercased()) } ||
            result.tags.contains { $0.lowercased().contains(term.lowercased()) }
        }
    }
    
    // MARK: - Exercise Operations
    
    func saveExercise(_ exercise: Exercise, to workout: Workout) async throws {
        if shouldThrowError { throw mockError }
        workout.exercises.append(exercise)
        mockExercises.append(exercise)
    }
    
    func updateExercise(_ exercise: Exercise, in workout: Workout) async throws {
        if shouldThrowError { throw mockError }
        if let index = mockExercises.firstIndex(where: { $0.id == exercise.id }) {
            mockExercises[index] = exercise
        }
    }
    
    func deleteExercise(_ exercise: Exercise, from workout: Workout) async throws {
        if shouldThrowError { throw mockError }
        workout.exercises.removeAll { $0.id == exercise.id }
        mockExercises.removeAll { $0.id == exercise.id }
    }
    
    func fetchExercises(for workout: Workout) async throws -> [Exercise] {
        if shouldThrowError { throw mockError }
        return workout.exercises
    }
    
    func fetchExercise(by id: UUID) async throws -> Exercise? {
        if shouldThrowError { throw mockError }
        return mockExercises.first { $0.id == id }
    }
    
    func fetchExercisesForDate(_ date: Date) async throws -> [Exercise] {
        if shouldThrowError { throw mockError }
        
        let calendar = Calendar.current
        let componentsOfDate = calendar.dateComponents([.day, .month, .year], from: date)
        
        return mockExercises.filter { exercise in
            // Check if exercise is scheduled for this date
            let componentsOfExercise = calendar.dateComponents([.day, .month, .year], from: exercise.startDate)
            if componentsOfDate == componentsOfExercise {
                return true
            }
            
            // Check repeat days
            var weekdayOfDate = (calendar.dateComponents([.weekday], from: date).weekday! + 6) % 7
            if weekdayOfDate == 0 { weekdayOfDate = 7 }
            let weekday = DayOfWeek(rawValue: weekdayOfDate)!
            return exercise.repeatDays.contains(weekday)
        }
    }
    
    // MARK: - Stopwatch Data Operations
    
    func saveStopwatchData(_ stopwatchData: StopwatchData) async throws {
        if shouldThrowError { throw mockError }
        mockStopwatchData.append(stopwatchData)
    }
    
    func updateStopwatchData(_ stopwatchData: StopwatchData) async throws {
        if shouldThrowError { throw mockError }
        if let index = mockStopwatchData.firstIndex(where: { $0.exerciseId == stopwatchData.exerciseId && Calendar.current.isDate($0.completionDate, inSameDayAs: stopwatchData.completionDate) }) {
            mockStopwatchData[index] = stopwatchData
        }
    }
    
    func deleteStopwatchData(_ stopwatchData: StopwatchData) async throws {
        if shouldThrowError { throw mockError }
        mockStopwatchData.removeAll { $0.exerciseId == stopwatchData.exerciseId && Calendar.current.isDate($0.completionDate, inSameDayAs: stopwatchData.completionDate) }
    }
    
    func fetchStopwatchData(for exerciseId: UUID, on date: Date) async throws -> StopwatchData? {
        if shouldThrowError { throw mockError }
        return mockStopwatchData.first { data in
            data.exerciseId == exerciseId && Calendar.current.isDate(data.completionDate, inSameDayAs: date)
        }
    }
    
    func fetchAllStopwatchData() async throws -> [StopwatchData] {
        if shouldThrowError { throw mockError }
        return mockStopwatchData
    }
    
    // MARK: - Settings Operations
    
    func saveSettings(_ settings: Settings) async throws {
        if shouldThrowError { throw mockError }
        mockSettings = settings
    }
    
    func fetchSettings() async throws -> Settings? {
        if shouldThrowError { throw mockError }
        return mockSettings
    }
    
    func updateSettings(_ settings: Settings) async throws {
        if shouldThrowError { throw mockError }
        mockSettings = settings
    }
    
    // MARK: - Sync Operations
    
    func syncAllData() async throws {
        if shouldThrowError { throw mockError }
        // Mock sync operation
    }
    
    func forceRefreshData() async throws {
        if shouldThrowError { throw mockError }
        forceRefreshCalled = true
        // Mock refresh operation
    }
    
    func clearLocalData() throws {
        if shouldThrowError { throw mockError }
        mockWorkouts.removeAll()
        mockExercises.removeAll()
        mockStopwatchData.removeAll()
        mockSettings = nil
    }
    
    func handleInitialLogin() async throws {
        if shouldThrowError { throw mockError }
        // Mock login handling
    }
}

// MARK: - Test Error

enum TestError: Error, LocalizedError {
    case mockError
    case networkError
    case dataCorruption
    
    var errorDescription: String? {
        switch self {
        case .mockError:
            return "This is a mock error for testing"
        case .networkError:
            return "Mock network error"
        case .dataCorruption:
            return "Mock data corruption error"
        }
    }
}
