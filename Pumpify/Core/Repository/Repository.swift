//
//  Repository.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 07.07.25.
//

import Foundation
import SwiftData
import Combine

// MARK: - Repository Protocols

protocol WorkoutRepositoryProtocol {
    func saveWorkout(_ workout: Workout) async throws
    func updateWorkout(_ workout: Workout) async throws
    func deleteWorkout(_ workout: Workout) async throws
    func fetchWorkouts() async throws -> [Workout]
    func fetchWorkout(by id: UUID) async throws -> Workout?
    func searchWorkouts(term: String) async throws -> [SearchResult]
}

protocol ExerciseRepositoryProtocol {
    func saveExercise(_ exercise: Exercise, to workout: Workout) async throws
    func updateExercise(_ exercise: Exercise, in workout: Workout) async throws
    func deleteExercise(_ exercise: Exercise, from workout: Workout) async throws
    func fetchExercises(for workout: Workout) async throws -> [Exercise]
    func fetchExercise(by id: UUID) async throws -> Exercise?
    func fetchExercisesForDate(_ date: Date) async throws -> [Exercise]
}

protocol StopwatchRepositoryProtocol {
    func saveStopwatchData(_ stopwatchData: StopwatchData) async throws
    func updateStopwatchData(_ stopwatchData: StopwatchData) async throws
    func deleteStopwatchData(_ stopwatchData: StopwatchData) async throws
    func fetchStopwatchData(for exerciseId: UUID, on date: Date) async throws -> StopwatchData?
    func fetchAllStopwatchData() async throws -> [StopwatchData]
}

protocol SettingsRepositoryProtocol {
    func saveSettings(_ settings: Settings) async throws
    func fetchSettings() async throws -> Settings?
    func updateSettings(_ settings: Settings) async throws
}

protocol SyncRepositoryProtocol {
    nonisolated var syncStatus: SyncStatus { get }
    nonisolated var syncError: Error? { get }
    func syncAllData() async throws
    func forceRefreshData() async throws
    func clearLocalData() throws
    func handleInitialLogin() async throws
}

// MARK: - Combined Repository Protocol

protocol DataRepositoryProtocol: WorkoutRepositoryProtocol, ExerciseRepositoryProtocol, StopwatchRepositoryProtocol, SettingsRepositoryProtocol, SyncRepositoryProtocol, ObservableObject {
    nonisolated var modelContext: ModelContext { get }
}
