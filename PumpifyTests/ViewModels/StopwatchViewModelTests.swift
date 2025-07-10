//
//  StopwatchViewModelTests.swift
//  PumpifyTests
//
//  Created by Unit Tests on 11.07.25.
//

import XCTest
import SwiftData
@testable import Pumpify

@MainActor
final class StopwatchViewModelTests: XCTestCase {
    
    var viewModel: StopwatchViewModel!
    var mockRepository: MockDataRepository!
    var testExerciseId: UUID!
    var testDate: Date!
    
    override func setUp() async throws {
        try await super.setUp()
        mockRepository = MockDataRepository()
        testExerciseId = UUID()
        testDate = Date()
        viewModel = StopwatchViewModel(
            exerciseId: testExerciseId,
            date: testDate,
            repository: mockRepository
        )
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockRepository = nil
        testExerciseId = nil
        testDate = nil
        try await super.tearDown()
    }
    
    // MARK: - Test Initial State
    
    func testInitialState() {
        // Then
        XCTAssertEqual(viewModel.timeElapsed, "00:00:00")
        XCTAssertFalse(viewModel.isRunning)
        XCTAssertFalse(viewModel.hasStarted)
        XCTAssertEqual(viewModel.previousElapsedTime, 0)
        XCTAssertEqual(viewModel.currentElapsedTime, 0)
        XCTAssertEqual(viewModel.period, 60)
        XCTAssertTrue(viewModel.stopwatchData.isEmpty)
        XCTAssertTrue(viewModel.allowsManualEntry)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
    
    // MARK: - Test Initialization with Existing Data
    
    func testInitializationWithExistingStopwatchData() {
        // Given
        let existingTime = Time(start: testDate, end: testDate.addingTimeInterval(300))
        let existingData = StopwatchData(
            completionDate: testDate,
            exerciseId: testExerciseId,
            times: [existingTime]
        )
        
        // When
        let viewModelWithExisting = StopwatchViewModel(
            exerciseId: testExerciseId,
            date: testDate,
            stopwatchDataToUpdate: existingData,
            repository: mockRepository
        )
        
        // Then
        XCTAssertEqual(viewModelWithExisting.stopwatchData.count, 1)
        XCTAssertEqual(viewModelWithExisting.previousElapsedTime, 300)
        XCTAssertEqual(viewModelWithExisting.timeElapsed, "00:05:00")
    }
    
    // MARK: - Test Stopwatch Controls
    
    func testStartStopwatch() {
        // When
        viewModel.start()
        
        // Then
        XCTAssertTrue(viewModel.isRunning)
        XCTAssertTrue(viewModel.hasStarted)
    }
    
    func testStopStopwatch() {
        // Given
        viewModel.start()
        
        // When
        viewModel.stop()
        
        // Then
        XCTAssertFalse(viewModel.isRunning)
        XCTAssertTrue(viewModel.hasStarted)
        XCTAssertEqual(viewModel.stopwatchData.count, 1)
        XCTAssertEqual(viewModel.currentElapsedTime, 0)
    }
    
    func testStartStopCycle() {
        // Given
        viewModel.start()
        
        // Allow some time to elapse
        let expectation = XCTestExpectation(description: "Timer update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        // When
        viewModel.stop()
        
        // Then
        XCTAssertFalse(viewModel.isRunning)
        XCTAssertTrue(viewModel.hasStarted)
        XCTAssertGreaterThan(viewModel.previousElapsedTime, 0)
        XCTAssertEqual(viewModel.currentElapsedTime, 0)
    }
    
    // MARK: - Test Time Calculations
    
    func testTotalElapsedTime() {
        // Given
        viewModel.previousElapsedTime = 300 // 5 minutes
        viewModel.currentElapsedTime = 120 // 2 minutes
        
        // When
        let totalTime = viewModel.totalElapsedTime
        
        // Then
        XCTAssertEqual(totalTime, 420) // 7 minutes
    }
    
    func testElapsedPeriods() {
        // Given
        viewModel.previousElapsedTime = 30
        viewModel.currentElapsedTime = 30
        viewModel.period = 60
        
        // When
        let periods = viewModel.elapsedPeriods
        
        // Then
        XCTAssertEqual(periods, 1.0) // 60 seconds / 60 second period = 1 period
    }
    
    // MARK: - Test Data Saving
    
    func testSaveStopwatchDataWithError() async {
        // Given
        viewModel.start()
        viewModel.stop()
        mockRepository.shouldThrowError = true
        
        // When
        let success = await viewModel.save()
        
        // Then
        XCTAssertFalse(success)
        XCTAssertNotNil(viewModel.error)
    }
    
    // MARK: - Test Manual Entry
    
    func testSaveManualEntry() async {
        // Given
        let startDate = testDate
        let endDate = testDate.addingTimeInterval(1800) // 30 minutes later
        
        viewModel.manualStartDate = startDate ?? Date()
        viewModel.manualEndDate = endDate
        
        // When
        let success = await viewModel.saveManual()
        
        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(mockRepository.mockStopwatchData.count, 1)
        XCTAssertEqual(mockRepository.mockStopwatchData.first?.totalInterval, 1800)
    }
    
    func testSaveManualEntryWithInvalidDates() async {
        // Given - end date before start date
        let startDate = testDate
        let endDate = testDate.addingTimeInterval(-1800) // 30 minutes earlier
        
        viewModel.manualStartDate = startDate ?? Date()
        viewModel.manualEndDate = endDate
        
        // When
        let success = await viewModel.saveManual()
        
        // Then
        XCTAssertFalse(success)
        XCTAssertTrue(mockRepository.mockStopwatchData.isEmpty)
    }
    
    func testSaveManualEntryWithError() async {
        // Given
        let startDate = testDate
        let endDate = testDate.addingTimeInterval(1800)
        
        viewModel.manualStartDate = startDate ?? Date()
        viewModel.manualEndDate = endDate
        mockRepository.shouldThrowError = true
        
        // When
        let success = await viewModel.saveManual()
        
        // Then
        XCTAssertFalse(success)
        XCTAssertNotNil(viewModel.error)
    }
    
    // MARK: - Test Reset Functionality
    
    func testResetStopwatchData() async {
        // Given
        viewModel.start()
        viewModel.stop()
        viewModel.hasStarted = true
        viewModel.previousElapsedTime = 300
        
        // When
        let success = await viewModel.resetStopwatchData()
        
        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(viewModel.currentElapsedTime, 0)
        XCTAssertFalse(viewModel.stopwatchData.isEmpty)
    }
    
    func testResetStopwatchDataWithError() async {
        // Given
        viewModel.hasStarted = true
        viewModel.previousElapsedTime = 300
        mockRepository.shouldThrowError = true
        
        // When
        let success = await viewModel.resetStopwatchData()
        
        // Then
        XCTAssertFalse(success)
        XCTAssertNotNil(viewModel.error)
    }
    
    // MARK: - Test Manual Date Initialization
    
    func testManualDateInitialization() {
        // Given
        let testDate = Date()
        let calendar = Calendar.current
        
        // When
        let viewModel = StopwatchViewModel(
            exerciseId: UUID(),
            date: testDate,
            repository: mockRepository
        )
        
        // Then
        let startComponents = calendar.dateComponents([.year, .month, .day], from: viewModel.manualStartDate)
        let endComponents = calendar.dateComponents([.year, .month, .day], from: viewModel.manualEndDate)
        let testComponents = calendar.dateComponents([.year, .month, .day], from: testDate)
        
        XCTAssertEqual(startComponents.year, testComponents.year)
        XCTAssertEqual(startComponents.month, testComponents.month)
        XCTAssertEqual(startComponents.day, testComponents.day)
        XCTAssertEqual(endComponents.year, testComponents.year)
        XCTAssertEqual(endComponents.month, testComponents.month)
        XCTAssertEqual(endComponents.day, testComponents.day)
        
        // End date should be later than start date
        XCTAssertGreaterThan(viewModel.manualEndDate, viewModel.manualStartDate)
    }
}
