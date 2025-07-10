//
//  HomeViewModelTests.swift
//  PumpifyTests
//
//  Created by Unit Tests on 11.07.25.
//

import XCTest
import SwiftData
@testable import Pumpify

@MainActor
final class HomeViewModelTests: XCTestCase {
    
    var viewModel: HomeViewModel!
    var mockRepository: MockDataRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        mockRepository = MockDataRepository()
        viewModel = HomeViewModel(repository: mockRepository)
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockRepository = nil
        try await super.tearDown()
    }
    
    // MARK: - Test Initial State
    
    func testInitialState() {
        // Then
        XCTAssertTrue(viewModel.todayExercises.isEmpty)
        XCTAssertTrue(viewModel.stopwatchData.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
    
    // MARK: - Test Data Loading
    
    func testLoadInitialData() async {
        // Given
        let exercise1 = createMockExercise(name: "Morning Run", startDate: Date())
        let exercise2 = createMockExercise(name: "Push-ups", startDate: Date())
        let stopwatchData = createMockStopwatchData(exerciseId: exercise1.id, totalTime: 300, date: Date())
        
        mockRepository.mockExercises = [exercise1, exercise2]
        mockRepository.mockStopwatchData = [stopwatchData]
        
        // When
        await viewModel.loadInitialData()
        
        // Then
        XCTAssertEqual(viewModel.todayExercises.count, 2)
        XCTAssertEqual(viewModel.stopwatchData.count, 1)
        XCTAssertEqual(viewModel.todayExercises.first?.name, "Morning Run")
    }
    
    func testLoadTodayExercises() async {
        // Given
        let todayExercise = createMockExercise(name: "Today's Exercise", startDate: Date())
        let yesterdayExercise = createMockExercise(name: "Yesterday's Exercise", startDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        
        mockRepository.mockExercises = [todayExercise, yesterdayExercise]
        
        // When
        await viewModel.loadTodayExercises()
        
        // Then
        XCTAssertTrue(viewModel.todayExercises.contains { $0.name == "Today's Exercise" })
    }
    
    func testLoadStopwatchData() async {
        // Given
        let exerciseId = UUID()
        let stopwatchData1 = createMockStopwatchData(exerciseId: exerciseId, totalTime: 300, date: Date())
        let stopwatchData2 = createMockStopwatchData(exerciseId: exerciseId, totalTime: 600, date: Date())
        
        mockRepository.mockStopwatchData = [stopwatchData1, stopwatchData2]
        
        // When
        await viewModel.loadStopwatchData()
        
        // Then
        XCTAssertEqual(viewModel.stopwatchData.count, 2)
        XCTAssertEqual(viewModel.stopwatchData.first?.totalInterval, 300)
    }
    
    // MARK: - Test Error Handling
    
    func testLoadInitialDataWithError() async {
        // Given
        mockRepository.shouldThrowError = true
        
        // When
        await viewModel.loadInitialData()
        
        // Then
        XCTAssertNotNil(viewModel.error)
        XCTAssertTrue(viewModel.todayExercises.isEmpty)
        XCTAssertTrue(viewModel.stopwatchData.isEmpty)
    }
    
    // MARK: - Test Data Refresh
    
    func testRefreshData() async {
        // Given
        let exercise = createMockExercise(name: "Refreshed Exercise", startDate: Date())
        mockRepository.mockExercises = [exercise]
        
        // When
        await viewModel.refreshData()
        
        // Then
        XCTAssertTrue(mockRepository.forceRefreshCalled)
        XCTAssertEqual(viewModel.todayExercises.count, 1)
        XCTAssertEqual(viewModel.todayExercises.first?.name, "Refreshed Exercise")
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
