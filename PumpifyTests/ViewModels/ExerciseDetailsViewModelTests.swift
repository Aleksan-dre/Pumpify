//
//  ExerciseDetailsViewModelTests.swift
//  PumpifyTests
//
//  Created by Unit Tests on 11.07.25.
//

import XCTest
import SwiftData
@testable import Pumpify

@MainActor
final class ExerciseDetailsViewModelTests: XCTestCase {
    
    var viewModel: ExerciseDetailsViewModel!
    var mockRepository: MockDataRepository!
    var testDate: Date!
    
    override func setUp() async throws {
        try await super.setUp()
        mockRepository = MockDataRepository()
        testDate = Date()
        viewModel = ExerciseDetailsViewModel(date: testDate, repository: mockRepository)
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockRepository = nil
        testDate = nil
        try await super.tearDown()
    }
    
    // MARK: - Test Initial State
    
    func testInitialState() {
        // Then
        XCTAssertTrue(viewModel.exercises.isEmpty)
        XCTAssertTrue(viewModel.stopwatchData.isEmpty)
        XCTAssertFalse(viewModel.showRestartStopwatchConfirmation)
        XCTAssertFalse(viewModel.showResetConfirmation)
        XCTAssertFalse(viewModel.navigatingToStopwatch)
        XCTAssertNil(viewModel.continuingStopwatchDatum)
        XCTAssertNil(viewModel.exerciseToReset)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
    
    // MARK: - Test Data Loading
    
    func testLoadData() async {
        // Given
        let exercise1 = createMockExercise(name: "Exercise 1", startDate: testDate)
        let exercise2 = createMockExercise(name: "Exercise 2", startDate: testDate)
        let stopwatchData = createMockStopwatchData(exerciseId: exercise1.id, totalTime: 300, date: testDate)
        
        mockRepository.mockExercises = [exercise1, exercise2]
        mockRepository.mockStopwatchData = [stopwatchData]
        
        // When
        await viewModel.loadData()
        
        // Then
        XCTAssertEqual(viewModel.exercises.count, 2)
        XCTAssertEqual(viewModel.stopwatchData.count, 1)
        XCTAssertEqual(viewModel.exercises.first?.name, "Exercise 1")
        XCTAssertEqual(viewModel.stopwatchData.first?.exerciseId, exercise1.id)
    }
    
    func testLoadExercises() async {
        // Given
        let exercise1 = createMockExercise(name: "Today's Exercise", startDate: testDate)
        let exercise2 = createMockExercise(name: "Yesterday's Exercise", startDate: Calendar.current.date(byAdding: .day, value: -1, to: testDate)!)
        
        mockRepository.mockExercises = [exercise1, exercise2]
        
        // When
        await viewModel.loadExercises()
        
        // Then
        XCTAssertTrue(viewModel.exercises.contains { $0.name == "Today's Exercise" })
    }
    
    func testLoadExercisesWithError() async {
        // Given
        mockRepository.shouldThrowError = true
        
        // When
        await viewModel.loadExercises()
        
        // Then
        XCTAssertNotNil(viewModel.error)
        XCTAssertTrue(viewModel.exercises.isEmpty)
    }
    
    func testLoadStopwatchData() async {
        // Given
        let exerciseId = UUID()
        let stopwatchData1 = createMockStopwatchData(exerciseId: exerciseId, totalTime: 300, date: testDate)
        let stopwatchData2 = createMockStopwatchData(exerciseId: exerciseId, totalTime: 600, date: testDate)
        
        mockRepository.mockStopwatchData = [stopwatchData1, stopwatchData2]
        
        // When
        await viewModel.loadStopwatchData()
        
        // Then
        XCTAssertEqual(viewModel.stopwatchData.count, 2)
        XCTAssertEqual(viewModel.stopwatchData.first?.totalInterval, 300)
        XCTAssertEqual(viewModel.stopwatchData.last?.totalInterval, 600)
    }
    
    func testLoadStopwatchDataWithError() async {
        // Given
        mockRepository.shouldThrowError = true
        
        // When
        await viewModel.loadStopwatchData()
        
        // Then
        XCTAssertNotNil(viewModel.error)
        XCTAssertTrue(viewModel.stopwatchData.isEmpty)
    }
    
    // MARK: - Test Stopwatch Data Retrieval
    
    func testGetStopwatchDataForExercise() {
        // Given
        let exercise = createMockExercise(name: "Test Exercise", startDate: testDate)
        let stopwatchData = createMockStopwatchData(exerciseId: exercise.id, totalTime: 300, date: testDate)
        
        viewModel.stopwatchData = [stopwatchData]
        
        // When
        let retrievedData = viewModel.getStopwatchData(for: exercise)
        
        // Then
        XCTAssertNotNil(retrievedData)
        XCTAssertEqual(retrievedData?.exerciseId, exercise.id)
        XCTAssertEqual(retrievedData?.totalInterval, 300)
    }
    
    func testGetStopwatchDataForExerciseWithNonMatchingDate() {
        // Given
        let exercise = createMockExercise(name: "Test Exercise", startDate: testDate)
        let differentDate = Calendar.current.date(byAdding: .day, value: 1, to: testDate)!
        let stopwatchData = createMockStopwatchData(exerciseId: exercise.id, totalTime: 300, date: differentDate)
        
        viewModel.stopwatchData = [stopwatchData]
        
        // When
        let retrievedData = viewModel.getStopwatchData(for: exercise)
        
        // Then
        XCTAssertNil(retrievedData)
    }
    
    func testGetStopwatchDataForExerciseWithNonMatchingExerciseId() {
        // Given
        let exercise = createMockExercise(name: "Test Exercise", startDate: testDate)
        let differentExerciseId = UUID()
        let stopwatchData = createMockStopwatchData(exerciseId: differentExerciseId, totalTime: 300, date: testDate)
        
        viewModel.stopwatchData = [stopwatchData]
        
        // When
        let retrievedData = viewModel.getStopwatchData(for: exercise)
        
        // Then
        XCTAssertNil(retrievedData)
    }
    
    func testHasStopwatchDataForExercise() {
        // Given
        let exercise = createMockExercise(name: "Test Exercise", startDate: testDate)
        let stopwatchData = createMockStopwatchData(exerciseId: exercise.id, totalTime: 300, date: testDate)
        
        viewModel.stopwatchData = [stopwatchData]
        
        // When
        let hasData = viewModel.hasStopwatchData(for: exercise)
        
        // Then
        XCTAssertTrue(hasData)
    }
    
    func testHasStopwatchDataForExerciseWithNoData() {
        // Given
        let exercise = createMockExercise(name: "Test Exercise", startDate: testDate)
        
        viewModel.stopwatchData = []
        
        // When
        let hasData = viewModel.hasStopwatchData(for: exercise)
        
        // Then
        XCTAssertFalse(hasData)
    }
    
    // MARK: - Test Stopwatch Navigation
    
    func testHandleStopwatchNavigationWithNoExistingData() {
        // Given
        let exercise = createMockExercise(name: "Test Exercise", startDate: testDate)
        
        // When
        viewModel.handleStopwatchNavigation(for: exercise)
        
        // Then
        XCTAssertTrue(viewModel.navigatingToStopwatch)
        XCTAssertFalse(viewModel.showRestartStopwatchConfirmation)
        XCTAssertNil(viewModel.continuingStopwatchDatum)
    }
    
    func testHandleStopwatchNavigationWithExistingData() {
        // Given
        let exercise = createMockExercise(name: "Test Exercise", startDate: testDate)
        let stopwatchData = createMockStopwatchData(exerciseId: exercise.id, totalTime: 300, date: testDate)
        
        viewModel.stopwatchData = [stopwatchData]
        
        // When
        viewModel.handleStopwatchNavigation(for: exercise)
        
        // Then
        XCTAssertFalse(viewModel.navigatingToStopwatch)
        XCTAssertTrue(viewModel.showRestartStopwatchConfirmation)
        XCTAssertEqual(viewModel.continuingStopwatchDatum?.exerciseId, exercise.id)
    }
    
    func testConfirmContinueStopwatch() {
        // Given
        viewModel.showRestartStopwatchConfirmation = true
        
        // When
        viewModel.confirmContinueStopwatch()
        
        // Then
        XCTAssertFalse(viewModel.showRestartStopwatchConfirmation)
        XCTAssertTrue(viewModel.navigatingToStopwatch)
    }
    
    func testCancelContinueStopwatch() {
        // Given
        let exercise = createMockExercise(name: "Test Exercise", startDate: testDate)
        let stopwatchData = createMockStopwatchData(exerciseId: exercise.id, totalTime: 300, date: testDate)
        
        viewModel.showRestartStopwatchConfirmation = true
        viewModel.continuingStopwatchDatum = stopwatchData
        
        // When
        viewModel.cancelContinueStopwatch()
        
        // Then
        XCTAssertFalse(viewModel.showRestartStopwatchConfirmation)
        XCTAssertNil(viewModel.continuingStopwatchDatum)
    }
    
    // MARK: - Test Exercise Reset
    
    func testResetExerciseData() {
        // Given
        let exercise = createMockExercise(name: "Test Exercise", startDate: testDate)
        
        // When
        viewModel.resetExerciseData(for: exercise)
        
        // Then
        XCTAssertTrue(viewModel.showResetConfirmation)
        XCTAssertEqual(viewModel.exerciseToReset?.id, exercise.id)
    }
    
    func testConfirmReset() async {
        // Given
        let exercise = createMockExercise(name: "Test Exercise", startDate: testDate)
        let stopwatchData = createMockStopwatchData(exerciseId: exercise.id, totalTime: 300, date: testDate)
        
        viewModel.stopwatchData = [stopwatchData]
        viewModel.exerciseToReset = exercise
        viewModel.showResetConfirmation = true
        
        // When
        await viewModel.confirmReset()
        
        // Then
        XCTAssertFalse(viewModel.showResetConfirmation)
        XCTAssertNil(viewModel.exerciseToReset)
        XCTAssertTrue(mockRepository.mockStopwatchData.isEmpty) // Data should be deleted
    }
    
    func testConfirmResetWithNoStopwatchData() async {
        // Given
        let exercise = createMockExercise(name: "Test Exercise", startDate: testDate)
        
        viewModel.exerciseToReset = exercise
        viewModel.showResetConfirmation = true
        
        // When
        await viewModel.confirmReset()
        
        // Then
        XCTAssertFalse(viewModel.showResetConfirmation)
        XCTAssertNil(viewModel.exerciseToReset)
        // Should complete without error even with no data to delete
    }
    
    func testConfirmResetWithError() async {
        // Given
        let exercise = createMockExercise(name: "Test Exercise", startDate: testDate)
        let stopwatchData = createMockStopwatchData(exerciseId: exercise.id, totalTime: 300, date: testDate)
        
        viewModel.stopwatchData = [stopwatchData]
        viewModel.exerciseToReset = exercise
        viewModel.showResetConfirmation = true
        mockRepository.shouldThrowError = true
        
        // When
        await viewModel.confirmReset()
        
        // Then
        XCTAssertFalse(viewModel.showResetConfirmation)
        XCTAssertNil(viewModel.exerciseToReset)
    }
    
    func testCancelReset() {
        // Given
        let exercise = createMockExercise(name: "Test Exercise", startDate: testDate)
        
        viewModel.exerciseToReset = exercise
        viewModel.showResetConfirmation = true
        
        // When
        viewModel.cancelReset()
        
        // Then
        XCTAssertFalse(viewModel.showResetConfirmation)
        XCTAssertNil(viewModel.exerciseToReset)
    }
    
    // MARK: - Test Data Refresh
    
    func testRefreshData() async {
        // Given
        let exercise = createMockExercise(name: "Refreshed Exercise", startDate: testDate)
        let stopwatchData = createMockStopwatchData(exerciseId: exercise.id, totalTime: 300, date: testDate)
        
        mockRepository.mockExercises = [exercise]
        mockRepository.mockStopwatchData = [stopwatchData]
        
        // When
        await viewModel.refreshData()
        
        // Then
        XCTAssertTrue(mockRepository.forceRefreshCalled)
        XCTAssertEqual(viewModel.exercises.count, 1)
        XCTAssertEqual(viewModel.stopwatchData.count, 1)
        XCTAssertEqual(viewModel.exercises.first?.name, "Refreshed Exercise")
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
}
