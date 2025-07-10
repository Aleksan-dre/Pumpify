//
//  NewWorkoutViewModelTests.swift
//  PumpifyTests
//
//  Created by Unit Tests on 11.07.25.
//

import XCTest
import SwiftData
@testable import Pumpify

@MainActor
final class NewWorkoutViewModelTests: XCTestCase {
    
    var viewModel: NewWorkoutViewModel!
    var mockRepository: MockDataRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        mockRepository = MockDataRepository()
        viewModel = NewWorkoutViewModel(repository: mockRepository)
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockRepository = nil
        try await super.tearDown()
    }
    
    // MARK: - Test Initial State
    
    func testInitialState() {
        // Then
        XCTAssertTrue(viewModel.name.isEmpty)
        XCTAssertEqual(viewModel.priority, 2)
        XCTAssertFalse(viewModel.isFormValid)
        XCTAssertNil(viewModel.settings)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        
        // Check that startDate is initialized to current time (within reasonable range)
        let timeDifference = abs(viewModel.startDate.timeIntervalSinceNow)
        XCTAssertLessThan(timeDifference, 1.0) // Within 1 second
    }
    
    // MARK: - Test Settings Loading
    
    func testLoadSettings() async {
        // Given
        let mockSettings = createMockSettings()
        mockRepository.mockSettings = mockSettings
        
        // When
        await viewModel.loadSettings()
        
        // Then
        XCTAssertNotNil(viewModel.settings)
        XCTAssertEqual(viewModel.settings?.firstName, "John")
        XCTAssertEqual(viewModel.settings?.accentColor, .blue)
    }
    
    func testLoadSettingsWithError() async {
        // Given
        mockRepository.shouldThrowError = true
        
        // When
        await viewModel.loadSettings()
        
        // Then
        XCTAssertNil(viewModel.settings)
        XCTAssertNotNil(viewModel.error)
    }
    
    // MARK: - Test Form Validation
    
    func testFormValidationWithValidName() {
        // When
        viewModel.name = "Morning Workout"
        
        // Then
        XCTAssertTrue(viewModel.isFormValid)
    }
    
    func testFormValidationWithEmptyName() {
        // When
        viewModel.name = ""
        
        // Then
        XCTAssertFalse(viewModel.isFormValid)
    }
    
    func testFormValidationWithWhitespaceOnlyName() {
        // When
        viewModel.name = "   "
        
        // Then
        XCTAssertFalse(viewModel.isFormValid)
    }
    
    func testFormValidationWithValidNameAfterTrimming() {
        // When
        viewModel.name = "  Morning Workout  "
        
        // Then
        XCTAssertTrue(viewModel.isFormValid)
    }
    
    func testFormValidationReactivity() {
        // Given
        viewModel.name = "Valid Name"
        XCTAssertTrue(viewModel.isFormValid)
        
        // When
        viewModel.name = ""
        
        // Then
        XCTAssertFalse(viewModel.isFormValid)
        
        // When
        viewModel.name = "Another Valid Name"
        
        // Then
        XCTAssertTrue(viewModel.isFormValid)
    }
    
    // MARK: - Test Workout Saving
    
    func testSaveWorkoutWithValidData() async {
        // Given
        viewModel.name = "Morning Workout"
        viewModel.startDate = Date()
        viewModel.priority = 3
        
        // When
        let success = await viewModel.saveWorkout()
        
        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(mockRepository.mockWorkouts.count, 1)
        XCTAssertEqual(mockRepository.mockWorkouts.first?.name, "Morning Workout")
        XCTAssertEqual(mockRepository.mockWorkouts.first?.priority, 3)
        XCTAssertEqual(mockRepository.mockWorkouts.first?.startDate, viewModel.startDate)
    }
    
    func testSaveWorkoutWithInvalidForm() async {
        // Given
        viewModel.name = "" // Invalid name
        
        // When
        let success = await viewModel.saveWorkout()
        
        // Then
        XCTAssertFalse(success)
        XCTAssertTrue(mockRepository.mockWorkouts.isEmpty)
    }
    
    func testSaveWorkoutTrimsWhitespace() async {
        // Given
        viewModel.name = "  Morning Workout  "
        
        // When
        let success = await viewModel.saveWorkout()
        
        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(mockRepository.mockWorkouts.first?.name, "Morning Workout")
    }
    
    func testSaveWorkoutWithEmptyNameAfterTrimming() async {
        // Given
        viewModel.name = "   " // Only whitespace
        
        // When
        let success = await viewModel.saveWorkout()
        
        // Then
        XCTAssertFalse(success)
        XCTAssertTrue(mockRepository.mockWorkouts.isEmpty)
    }
    
    func testSaveWorkoutWithRepositoryError() async {
        // Given
        viewModel.name = "Morning Workout"
        mockRepository.shouldThrowError = true
        
        // When
        let success = await viewModel.saveWorkout()
        
        // Then
        XCTAssertFalse(success)
        XCTAssertNotNil(viewModel.error)
        XCTAssertTrue(mockRepository.mockWorkouts.isEmpty)
    }
    
    // MARK: - Test Priority Management
    
    func testPriorityDefaultValue() {
        // Then
        XCTAssertEqual(viewModel.priority, 2)
    }
    
    func testPriorityUpdate() {
        // When
        viewModel.priority = 1
        
        // Then
        XCTAssertEqual(viewModel.priority, 1)
        
        // When
        viewModel.priority = 3
        
        // Then
        XCTAssertEqual(viewModel.priority, 3)
    }
    
    func testSaveWorkoutWithDifferentPriorities() async {
        // Test priority 1
        viewModel.name = "Low Priority Workout"
        viewModel.priority = 1
        
        var success = await viewModel.saveWorkout()
        
        XCTAssertTrue(success)
        XCTAssertEqual(mockRepository.mockWorkouts.last?.priority, 1)
        
        // Test priority 3
        viewModel.name = "High Priority Workout"
        viewModel.priority = 3
        
        success = await viewModel.saveWorkout()
        
        XCTAssertTrue(success)
        XCTAssertEqual(mockRepository.mockWorkouts.last?.priority, 3)
    }
    
    // MARK: - Test Date Management
    
    func testStartDateInitialization() {
        // Then
        let timeDifference = abs(viewModel.startDate.timeIntervalSinceNow)
        XCTAssertLessThan(timeDifference, 1.0) // Within 1 second of now
    }
    
    func testStartDateUpdate() {
        // Given
        let futureDate = Date().addingTimeInterval(86400) // Tomorrow
        
        // When
        viewModel.startDate = futureDate
        
        // Then
        XCTAssertEqual(viewModel.startDate, futureDate)
    }
    
    func testSaveWorkoutWithCustomStartDate() async {
        // Given
        let customDate = Date().addingTimeInterval(-86400) // Yesterday
        viewModel.name = "Custom Date Workout"
        viewModel.startDate = customDate
        
        // When
        let success = await viewModel.saveWorkout()
        
        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(mockRepository.mockWorkouts.first?.startDate, customDate)
    }
    
    // MARK: - Test Form Reset
    
    func testResetForm() {
        // Given
        viewModel.name = "Test Workout"
        viewModel.startDate = Date().addingTimeInterval(-86400) // Yesterday
        viewModel.priority = 3
        
        // When
        viewModel.resetForm()
        
        // Then
        XCTAssertTrue(viewModel.name.isEmpty)
        XCTAssertEqual(viewModel.priority, 2)
        
        // Check that startDate is reset to current time (within reasonable range)
        let timeDifference = abs(viewModel.startDate.timeIntervalSinceNow)
        XCTAssertLessThan(timeDifference, 1.0) // Within 1 second
    }
    
    // MARK: - Test Workout Creation
    
    func testWorkoutCreationWithAllProperties() async {
        // Given
        let workoutName = "Complete Morning Routine"
        let workoutDate = Date().addingTimeInterval(3600) // 1 hour from now
        let workoutPriority = 1
        
        viewModel.name = workoutName
        viewModel.startDate = workoutDate
        viewModel.priority = workoutPriority
        
        // When
        let success = await viewModel.saveWorkout()
        
        // Then
        XCTAssertTrue(success)
        
        guard let savedWorkout = mockRepository.mockWorkouts.first else {
            XCTFail("No workout was saved")
            return
        }
        
        XCTAssertEqual(savedWorkout.name, workoutName)
        XCTAssertEqual(savedWorkout.startDate, workoutDate)
        XCTAssertEqual(savedWorkout.priority, workoutPriority)
        XCTAssertTrue(savedWorkout.exercises.isEmpty) // New workout should have no exercises
        XCTAssertNotNil(savedWorkout.id) // Should have a valid ID
    }
    
    // MARK: - Test Error Handling
    
    func testErrorHandlingDoesNotAffectFormState() async {
        // Given
        viewModel.name = "Test Workout"
        viewModel.priority = 3
        let originalStartDate = viewModel.startDate
        
        mockRepository.shouldThrowError = true
        
        // When
        let success = await viewModel.saveWorkout()
        
        // Then
        XCTAssertFalse(success)
        XCTAssertNotNil(viewModel.error)
        
        // Form state should remain unchanged
        XCTAssertEqual(viewModel.name, "Test Workout")
        XCTAssertEqual(viewModel.priority, 3)
        XCTAssertEqual(viewModel.startDate, originalStartDate)
    }
    
    // MARK: - Helper Methods
    
    private func createMockSettings() -> Settings {
        let settings = Settings()
        settings.firstName = "John"
        settings.lastName = "Doe"
        settings.email = "john@example.com"
        settings.accentColor = .blue
        settings.dynamicFontSize = 16
        return settings
    }
}
