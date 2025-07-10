//
//  WorkoutsViewModelTests.swift
//  PumpifyTests
//
//  Created by Unit Tests on 11.07.25.
//

import XCTest
import SwiftData
@testable import Pumpify

@MainActor
final class WorkoutsViewModelTests: XCTestCase {
    
    var viewModel: WorkoutsViewModel!
    var mockRepository: MockDataRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        mockRepository = MockDataRepository()
        viewModel = WorkoutsViewModel(repository: mockRepository)
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockRepository = nil
        try await super.tearDown()
    }
    
    // MARK: - Test Initial State
    
    func testInitialState() {
        // Then
        XCTAssertTrue(viewModel.workouts.isEmpty)
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertTrue(viewModel.searchTerm.isEmpty)
        XCTAssertFalse(viewModel.isSearching)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
    
    // MARK: - Test Data Loading
    
    func testLoadExercises() async {
        // Given
        let workout1 = createMockWorkout(name: "Morning Workout", exercises: [])
        let workout2 = createMockWorkout(name: "Evening Workout", exercises: [])
        
        mockRepository.mockWorkouts = [workout1, workout2]
        
        // When
        await viewModel.loadExercises()
        
        // Then
        XCTAssertEqual(viewModel.workouts.count, 2)
        XCTAssertEqual(viewModel.workouts.first?.name, "Morning Workout")
        XCTAssertEqual(viewModel.workouts.last?.name, "Evening Workout")
    }
    
    func testLoadExercisesWithError() async {
        // Given
        mockRepository.shouldThrowError = true
        
        // When
        await viewModel.loadExercises()
        
        // Then
        XCTAssertNotNil(viewModel.error)
        XCTAssertTrue(viewModel.workouts.isEmpty)
    }
    
    // MARK: - Test Search Functionality
    
    func testPerformSearchWithValidTerm() async {
        // Given
        let searchTerm = "cardio"
        let exercise = createMockExercise(name: "Cardio Workout", startDate: Date())
        let workout = createMockWorkout(name: "Cardio Session", exercises: [exercise])
        
        let searchResult = SearchResult(
            workout: workout,
            exercises: [exercise],
            tags: ["cardio"],
            findReasons: [.workout]
        )
        
        mockRepository.mockSearchResults = [searchResult]
        
        // When
        await viewModel.performSearch(term: searchTerm)
        
        // Then
        XCTAssertEqual(viewModel.searchResults.count, 1)
        XCTAssertEqual(viewModel.searchResults.first?.workout.name, "Cardio Session")
        XCTAssertEqual(viewModel.searchResults.first?.tags.first, "cardio")
    }
    
    func testPerformSearchWithEmptyTerm() async {
        // Given
        let emptyTerm = ""
        mockRepository.mockSearchResults = [createMockSearchResult()]
        
        // When
        await viewModel.performSearch(term: emptyTerm)
        
        // Then
        XCTAssertTrue(viewModel.searchResults.isEmpty)
    }
    
    func testPerformSearchWithError() async {
        // Given
        mockRepository.shouldThrowError = true
        
        // When
        await viewModel.performSearch(term: "test")
        
        // Then
        XCTAssertNotNil(viewModel.error)
        XCTAssertTrue(viewModel.searchResults.isEmpty)
    }
    
    // MARK: - Test Search Term Debouncing
    
    func testSearchTermDebouncing() async {
        // Given
        let searchResult = createMockSearchResult()
        mockRepository.mockSearchResults = [searchResult]
        
        // When
        viewModel.searchTerm = "test"
        
        // Wait for debounce
        try? await Task.sleep(nanoseconds: 400_000_000) // 400ms
        
        // Then
        XCTAssertEqual(viewModel.searchResults.count, 1)
    }
    
    // MARK: - Test Workout Deletion
    
    func testDeleteAtOffsets() async {
        // Given
        let workout1 = createMockWorkout(name: "Workout 1", exercises: [])
        let workout2 = createMockWorkout(name: "Workout 2", exercises: [])
        let workout3 = createMockWorkout(name: "Workout 3", exercises: [])
        
        mockRepository.mockWorkouts = [workout1, workout2, workout3]
        viewModel.workouts = [workout1, workout2, workout3]
        
        let offsetsToDelete = IndexSet([0, 2]) // Delete first and third workouts
        
        // When
        await viewModel.delete(at: offsetsToDelete)
        
        // Then
        XCTAssertEqual(viewModel.workouts.count, 1)
        XCTAssertEqual(viewModel.workouts.first?.name, "Workout 2")
    }
    
    func testDeleteWorkoutWithExercises() async {
        // Given
        let exercise1 = createMockExercise(name: "Exercise 1", startDate: Date())
        let exercise2 = createMockExercise(name: "Exercise 2", startDate: Date())
        let workout = createMockWorkout(name: "Workout with Exercises", exercises: [exercise1, exercise2])
        
        let stopwatchData1 = createMockStopwatchData(exerciseId: exercise1.id, totalTime: 300, date: Date())
        let stopwatchData2 = createMockStopwatchData(exerciseId: exercise2.id, totalTime: 600, date: Date())
        
        mockRepository.mockWorkouts = [workout]
        mockRepository.mockStopwatchData = [stopwatchData1, stopwatchData2]
        viewModel.workouts = [workout]
        
        // When
        await viewModel.delete(at: IndexSet([0]))
        
        // Then
        XCTAssertTrue(viewModel.workouts.isEmpty)
        // Verify that related stopwatch data was also deleted
        XCTAssertTrue(mockRepository.mockStopwatchData.isEmpty)
    }
    
    func testDeleteWithError() async {
        // Given
        let workout = createMockWorkout(name: "Test Workout", exercises: [])
        mockRepository.mockWorkouts = [workout]
        viewModel.workouts = [workout]
        mockRepository.shouldThrowError = true
        
        // When
        await viewModel.delete(at: IndexSet([0]))
        
        // Then
        XCTAssertNotNil(viewModel.error)
        XCTAssertEqual(viewModel.workouts.count, 1) // Should remain unchanged on error
    }
    
    // MARK: - Test Data Refresh
    
    func testRefreshData() async {
        // Given
        let newWorkout = createMockWorkout(name: "Refreshed Workout", exercises: [])
        mockRepository.mockWorkouts = [newWorkout]
        
        // When
        await viewModel.refreshData()
        
        // Then
        XCTAssertTrue(mockRepository.forceRefreshCalled)
        XCTAssertEqual(viewModel.workouts.count, 1)
        XCTAssertEqual(viewModel.workouts.first?.name, "Refreshed Workout")
    }
    
    func testRefreshDataWithError() async {
        // Given
        mockRepository.shouldThrowError = true
        
        // When
        await viewModel.refreshData()
        
        // Then
        XCTAssertNotNil(viewModel.error)
    }
    
    // MARK: - Helper Methods
    
    private func createMockWorkout(name: String, exercises: [Exercise]) -> Workout {
        return Workout(
            name: name,
            exercises: exercises,
            startDate: Date(),
            priority: 2
        )
    }
    
    private func createMockExercise(name: String, startDate: Date) -> Exercise {
        return Exercise(
            name: name,
            tags: [],
            startDate: startDate,
            priority: 2,
            repeatDays: []
        )
    }
    
    private func createMockStopwatchData(exerciseId: UUID, totalTime: TimeInterval, date: Date) -> StopwatchData {
        let times = [Time(start: date, end: date.addingTimeInterval(totalTime))]
        return StopwatchData(
            completionDate: date,
            exerciseId: exerciseId,
            times: times
        )
    }
    
    private func createMockSearchResult() -> SearchResult {
        let exercise = createMockExercise(name: "Test Exercise", startDate: Date())
        let workout = createMockWorkout(name: "Test Workout", exercises: [exercise])
        
        return SearchResult(
            workout: workout,
            exercises: [exercise],
            tags: ["test"],
            findReasons: [.workout]
        )
    }
}
