//
//  NewExerciseViewModelTests.swift
//  PumpifyTests
//
//  Created by Unit Tests on 11.07.25.
//

import XCTest
import SwiftData
@testable import Pumpify

@MainActor
final class NewExerciseViewModelTests: XCTestCase {
    
    var viewModel: NewExerciseViewModel!
    var mockRepository: MockDataRepository!
    var testWorkout: Workout!
    
    override func setUp() async throws {
        try await super.setUp()
        mockRepository = MockDataRepository()
        testWorkout = createMockWorkout()
        viewModel = NewExerciseViewModel(workout: testWorkout, repository: mockRepository)
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockRepository = nil
        testWorkout = nil
        try await super.tearDown()
    }
    
    // MARK: - Test Initial State
    
    func testInitialState() {
        // Then
        XCTAssertTrue(viewModel.name.isEmpty)
        XCTAssertTrue(viewModel.tags.isEmpty)
        XCTAssertEqual(viewModel.priority, 2)
        XCTAssertTrue(viewModel.repeatDays.isEmpty)
        XCTAssertFalse(viewModel.showNewTagPopup)
        XCTAssertFalse(viewModel.isFormValid)
        XCTAssertNil(viewModel.settings)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
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
        viewModel.name = "Push-ups"
        
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
        viewModel.name = "  Push-ups  "
        
        // Then
        XCTAssertTrue(viewModel.isFormValid)
    }
    
    // MARK: - Test Exercise Saving
    
    func testSaveExerciseWithValidData() async {
        // Given
        viewModel.name = "Push-ups"
        viewModel.startDate = Date()
        viewModel.priority = 3
        viewModel.tags = ["strength", "bodyweight"]
        viewModel.repeatDays = [.monday, .wednesday, .friday]
        
        // When
        let success = await viewModel.saveExercise()
        
        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(testWorkout.exercises.count, 1)
        XCTAssertEqual(testWorkout.exercises.first?.name, "Push-ups")
        XCTAssertEqual(testWorkout.exercises.first?.priority, 3)
        XCTAssertEqual(testWorkout.exercises.first?.tags, ["strength", "bodyweight"])
        XCTAssertEqual(testWorkout.exercises.first?.repeatDays, [.monday, .wednesday, .friday])
    }
    
    func testSaveExerciseWithInvalidForm() async {
        // Given
        viewModel.name = "" // Invalid name
        
        // When
        let success = await viewModel.saveExercise()
        
        // Then
        XCTAssertFalse(success)
        XCTAssertTrue(testWorkout.exercises.isEmpty)
    }
    
    func testSaveExerciseWithDuplicateName() async {
        // Given
        let existingExercise = Exercise(
            name: "Push-ups",
            tags: [],
            startDate: Date(),
            priority: 2,
            repeatDays: []
        )
        testWorkout.exercises.append(existingExercise)
        
        viewModel.name = "Push-ups" // Same name as existing
        
        // When
        let success = await viewModel.saveExercise()
        
        // Then
        XCTAssertFalse(success)
        XCTAssertEqual(testWorkout.exercises.count, 1) // Only the original exercise
    }
    
    func testSaveExerciseWithDuplicateNameCaseInsensitive() async {
        // Given
        let existingExercise = Exercise(
            name: "Push-ups",
            tags: [],
            startDate: Date(),
            priority: 2,
            repeatDays: []
        )
        testWorkout.exercises.append(existingExercise)
        
        viewModel.name = "PUSH-UPS" // Same name but different case
        
        // When
        let success = await viewModel.saveExercise()
        
        // Then
        XCTAssertFalse(success)
        XCTAssertEqual(testWorkout.exercises.count, 1) // Only the original exercise
    }
    
    func testSaveExerciseWithRepositoryError() async {
        // Given
        viewModel.name = "Push-ups"
        mockRepository.shouldThrowError = true
        
        // When
        let success = await viewModel.saveExercise()
        
        // Then
        XCTAssertFalse(success)
        XCTAssertNotNil(viewModel.error)
    }
    
    func testSaveExerciseTrimsWhitespace() async {
        // Given
        viewModel.name = "  Push-ups  "
        
        // When
        let success = await viewModel.saveExercise()
        
        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(testWorkout.exercises.first?.name, "Push-ups")
    }
    
    // MARK: - Test Tag Management
    
    func testAddTag() {
        // Given
        let tag = "strength"
        
        // When
        viewModel.addTag(tag)
        
        // Then
        XCTAssertEqual(viewModel.tags.count, 1)
        XCTAssertEqual(viewModel.tags.first, "strength")
    }
    
    func testAddTagWithWhitespace() {
        // Given
        let tag = "  strength  "
        
        // When
        viewModel.addTag(tag)
        
        // Then
        XCTAssertEqual(viewModel.tags.count, 1)
        XCTAssertEqual(viewModel.tags.first, "strength")
    }
    
    func testAddEmptyTag() {
        // Given
        let tag = ""
        
        // When
        viewModel.addTag(tag)
        
        // Then
        XCTAssertTrue(viewModel.tags.isEmpty)
    }
    
    func testAddWhitespaceOnlyTag() {
        // Given
        let tag = "   "
        
        // When
        viewModel.addTag(tag)
        
        // Then
        XCTAssertTrue(viewModel.tags.isEmpty)
    }
    
    func testAddDuplicateTag() {
        // Given
        viewModel.tags = ["strength"]
        
        // When
        viewModel.addTag("strength")
        
        // Then
        XCTAssertEqual(viewModel.tags.count, 1)
        XCTAssertEqual(viewModel.tags.first, "strength")
    }
    
    func testRemoveTag() {
        // Given
        viewModel.tags = ["strength", "cardio", "flexibility"]
        
        // When
        viewModel.removeTag(at: IndexSet([1])) // Remove "cardio"
        
        // Then
        XCTAssertEqual(viewModel.tags.count, 2)
        XCTAssertEqual(viewModel.tags, ["strength", "flexibility"])
    }
    
    func testRemoveMultipleTags() {
        // Given
        viewModel.tags = ["strength", "cardio", "flexibility", "balance"]
        
        // When
        viewModel.removeTag(at: IndexSet([1, 3])) // Remove "cardio" and "balance"
        
        // Then
        XCTAssertEqual(viewModel.tags.count, 2)
        XCTAssertEqual(viewModel.tags, ["strength", "flexibility"])
    }
    
    // MARK: - Test UI State Management
    
    func testToggleTagPopup() {
        // Given
        let initialState = viewModel.showNewTagPopup
        
        // When
        viewModel.toggleTagPopup()
        
        // Then
        XCTAssertNotEqual(viewModel.showNewTagPopup, initialState)
    }
    
    func testToggleTagPopupMultipleTimes() {
        // Given
        let initialState = viewModel.showNewTagPopup
        
        // When
        viewModel.toggleTagPopup()
        viewModel.toggleTagPopup()
        
        // Then
        XCTAssertEqual(viewModel.showNewTagPopup, initialState)
    }
    
    // MARK: - Test Form Reset
    
    func testResetForm() {
        // Given
        viewModel.name = "Push-ups"
        viewModel.startDate = Date().addingTimeInterval(-86400) // Yesterday
        viewModel.priority = 3
        viewModel.tags = ["strength", "bodyweight"]
        viewModel.repeatDays = [.monday, .wednesday, .friday]
        
        // When
        viewModel.resetForm()
        
        // Then
        XCTAssertTrue(viewModel.name.isEmpty)
        XCTAssertTrue(viewModel.tags.isEmpty)
        XCTAssertEqual(viewModel.priority, 2)
        XCTAssertTrue(viewModel.repeatDays.isEmpty)
        
        // Check that startDate is reset to current time (within reasonable range)
        let timeDifference = abs(viewModel.startDate.timeIntervalSinceNow)
        XCTAssertLessThan(timeDifference, 1.0) // Within 1 second
    }
    
    // MARK: - Test Repeat Days
    
    func testRepeatDaysManagement() {
        // Given
        let weekdays: Set<DayOfWeek> = [.monday, .tuesday, .wednesday, .thursday, .friday]
        
        // When
        viewModel.repeatDays = weekdays
        
        // Then
        XCTAssertEqual(viewModel.repeatDays.count, 5)
        XCTAssertTrue(viewModel.repeatDays.contains(.monday))
        XCTAssertTrue(viewModel.repeatDays.contains(.friday))
        XCTAssertFalse(viewModel.repeatDays.contains(.saturday))
    }
    
    func testEmptyRepeatDays() {
        // Given
        viewModel.repeatDays = [.monday, .tuesday]
        
        // When
        viewModel.repeatDays = []
        
        // Then
        XCTAssertTrue(viewModel.repeatDays.isEmpty)
    }
    
    // MARK: - Helper Methods
    
    private func createMockWorkout() -> Workout {
        return Workout(
            name: "Test Workout",
            exercises: [],
            startDate: Date(),
            priority: 2
        )
    }
    
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
