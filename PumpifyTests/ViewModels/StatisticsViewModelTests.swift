//
//  StatisticsViewModelTests.swift
//  PumpifyTests
//
//  Created by Aleksandre Shalikashvili on 11.07.25.
//

import XCTest
import SwiftData
@testable import Pumpify

@MainActor
final class StatisticsViewModelTests: XCTestCase {
    
    var viewModel: StatisticsViewModel!
    var mockRepository: MockDataRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        mockRepository = MockDataRepository()
        viewModel = StatisticsViewModel(repository: mockRepository)
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockRepository = nil
        try await super.tearDown()
    }
    
    // MARK: - Test Period Selection
    
    func testPeriodSelection() async throws {
        // Given
        let initialPeriod = viewModel.selectedPeriod
        
        // When
        viewModel.selectedPeriod = .month
        
        // Then
        XCTAssertNotEqual(viewModel.selectedPeriod, initialPeriod)
    }
    
    func testDateSelection() async throws {
        // Given
        let testDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        
        // When
        viewModel.selectedDate = testDate
        
        // Then
        XCTAssertEqual(viewModel.selectedDate, testDate)
    }
        
    // MARK: - Test Statistics Calculations
    
    func testTotalTimeCalculation() async throws {
        // Given
        let testDate = Date()
        let exercise1 = createMockExercise(name: "Push-ups")
        let exercise2 = createMockExercise(name: "Squats")
        
        let stopwatchData = [
            createMockStopwatchData(exerciseId: exercise1.id, totalTime: 300, date: testDate), // 5 minutes
            createMockStopwatchData(exerciseId: exercise2.id, totalTime: 600, date: testDate)  // 10 minutes
        ]
        
        mockRepository.mockStopwatchData = stopwatchData
        mockRepository.mockExercises = [exercise1, exercise2]
        
        // When
        await viewModel.loadData()
        
        // Then
        XCTAssertEqual(viewModel.totalTimeThisPeriod, 900) // 15 minutes total
        XCTAssertEqual(viewModel.completedExercisesThisPeriod, 2)
    }
    
    func testMostActiveDayCalculation() async throws {
        // Given
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        let exercise = createMockExercise(name: "Running")
        
        let stopwatchData = [
            createMockStopwatchData(exerciseId: exercise.id, totalTime: 1800, date: today),     // 30 min today
            createMockStopwatchData(exerciseId: exercise.id, totalTime: 600, date: yesterday)   // 10 min yesterday
        ]
        
        mockRepository.mockStopwatchData = stopwatchData
        mockRepository.mockExercises = [exercise]
        
        // When
        await viewModel.loadData()
        
        // Then
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let expectedDay = formatter.string(from: today)
        
        XCTAssertEqual(viewModel.mostActiveDay, expectedDay)
    }
    
    // MARK: - Helper Methods
    
    private func createMockExercise(name: String) -> Exercise {
        return Exercise(
            name: name,
            tags: [],
            startDate: Date(),
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

// MARK: - Test Data Loading and Refreshing

extension StatisticsViewModelTests {
    
    func testDataLoading() async throws {
        // Given
        let exercise = createMockExercise(name: "Test Exercise")
        let stopwatchData = [createMockStopwatchData(exerciseId: exercise.id, totalTime: 300, date: Date())]
        
        mockRepository.mockExercises = [exercise]
        mockRepository.mockStopwatchData = stopwatchData
        
        // When
        await viewModel.loadData()
        
        // Then
        XCTAssertEqual(viewModel.stopwatchData.count, 1)
    }
    
    func testDataRefresh() async throws {
        // Given
        let exercise = createMockExercise(name: "Refreshed Exercise")
        mockRepository.mockExercises = [exercise]
        
        // When
        await viewModel.refreshData()
        
        // Then
        XCTAssertTrue(mockRepository.forceRefreshCalled)
    }
}
