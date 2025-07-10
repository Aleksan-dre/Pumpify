//
//  CalendarViewModelTests.swift
//  PumpifyTests
//
//  Created by TimurSmoev on 11.07.25.
//

import XCTest
@testable import Pumpify

@MainActor
final class CalendarViewModelTests: XCTestCase {
    
    var viewModel: CalendarViewModel!
    var mockRepository: MockDataRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        mockRepository = MockDataRepository()
        viewModel = CalendarViewModel(repository: mockRepository)
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockRepository = nil
        try await super.tearDown()
    }
    
    // MARK: - Test Date Calculations
    
    func testDaysInMonth() {
        // Given
        let july2025 = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 1))!
        viewModel.currentMonth = july2025
        
        // When
        let daysInMonth = viewModel.daysInMonth(date: july2025)
        
        // Then
        XCTAssertEqual(daysInMonth, 31, "July 2025 should have 31 days")
    }
    
    func testDaysInMonthLeapYear() {
        // Given
        let february2024 = Calendar.current.date(from: DateComponents(year: 2024, month: 2, day: 1))!
        viewModel.currentMonth = february2024
        
        // When
        let daysInMonth = viewModel.daysInMonth(date: february2024)
        
        // Then
        XCTAssertEqual(daysInMonth, 29, "February 2024 (leap year) should have 29 days")
    }
    
    func testDayInMonthArray() {
        // Given
        let july2025 = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 1))!
        viewModel.currentMonth = july2025
        
        // When
        let dayInMonth = viewModel.dayInMonth
        
        // Then
        XCTAssertEqual(dayInMonth.count, 31, "Should generate 31 dates for July 2025")
        
        // Check first and last dates
        if let firstDate = dayInMonth.first,
           let lastDate = dayInMonth.last {
            let firstComponents = Calendar.current.dateComponents([.day], from: firstDate)
            let lastComponents = Calendar.current.dateComponents([.day], from: lastDate)
            
            XCTAssertEqual(firstComponents.day, 1, "First date should be day 1")
            XCTAssertEqual(lastComponents.day, 31, "Last date should be day 31")
        }
    }
    
    // MARK: - Test Exercise Filtering
    
    func testExercisesInDay() {
        // Given
        let testDate = Date()
        let exercise1 = createMockExercise(name: "Morning Run", startDate: testDate, repeatDays: [])
        let exercise2 = createMockExercise(name: "Evening Workout", startDate: Calendar.current.date(byAdding: .day, value: 1, to: testDate)!, repeatDays: [])
        let exercise3 = createMockExercise(name: "Daily Exercise", startDate: Calendar.current.date(byAdding: .day, value: -7, to: testDate)!, repeatDays: Set(DayOfWeek.all))
        
        let workout = createMockWorkout(name: "Test Workout", exercises: [exercise1, exercise2, exercise3])
        mockRepository.mockWorkouts = [workout]
        mockRepository.mockExercises = [exercise1, exercise2, exercise3]
        viewModel.workouts = [workout]
        
        // When
        let exercisesForToday = viewModel.exercisesInDay(date: testDate)
        
        // Then
        XCTAssertEqual(exercisesForToday.count, 2, "Should have 2 exercises for today")
        
        let exerciseNames = exercisesForToday.map { $0.name }
        XCTAssertTrue(exerciseNames.contains("Morning Run"), "Should include exercise scheduled for today")
        XCTAssertTrue(exerciseNames.contains("Daily Exercise"), "Should include repeating daily exercise")
        XCTAssertFalse(exerciseNames.contains("Evening Workout"), "Should not include tomorrow's exercise")
    }
    
    func testExercisesInDayWithRepeatDays() {
        // Given
        let calendar = Calendar.current
        let today = Date()
        
        // Find next Monday
        var dateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        dateComponents.weekday = 2 // Monday
        let nextMonday = calendar.date(from: dateComponents)!
        
        let exercise = createMockExercise(
            name: "Monday Workout",
            startDate: calendar.date(byAdding: .day, value: -7, to: nextMonday)!, // Started last week
            repeatDays: [.monday]
        )
        
        let workout = createMockWorkout(name: "Weekly Workout", exercises: [exercise])
        mockRepository.mockWorkouts = [workout]
        mockRepository.mockExercises = [exercise]
        viewModel.workouts = [workout]
        
        // When
        let exercisesForMonday = viewModel.exercisesInDay(date: nextMonday)
        let exercisesForTuesday = viewModel.exercisesInDay(date: calendar.date(byAdding: .day, value: 1, to: nextMonday)!)
        
        // Then
        XCTAssertEqual(exercisesForMonday.count, 1, "Should have 1 exercise on Monday")
        XCTAssertEqual(exercisesForTuesday.count, 0, "Should have 0 exercises on Tuesday")
        XCTAssertEqual(exercisesForMonday.first?.name, "Monday Workout")
    }
    
    // MARK: - Test Workout Exercises Grouping
    
    func testWorkoutExercisesForDate() {
        // Given
        let testDate = Date()
        let exercise1 = createMockExercise(name: "Exercise 1", startDate: testDate, repeatDays: [])
        let exercise2 = createMockExercise(name: "Exercise 2", startDate: testDate, repeatDays: [])
        let exercise3 = createMockExercise(name: "Exercise 3", startDate: Calendar.current.date(byAdding: .day, value: 1, to: testDate)!, repeatDays: [])
        
        let workout1 = createMockWorkout(name: "Workout A", exercises: [exercise1, exercise2])
        let workout2 = createMockWorkout(name: "Workout B", exercises: [exercise3])
        
        mockRepository.mockWorkouts = [workout1, workout2]
        mockRepository.mockExercises = [exercise1, exercise2, exercise3]
        viewModel.workouts = [workout1, workout2]
        
        // When
        let workoutExercises = viewModel.workoutExercisesForDate(testDate)
        
        // Then
        XCTAssertEqual(workoutExercises.count, 1, "Should have 1 workout with exercises for today")
        
        if let firstGroup = workoutExercises.first {
            XCTAssertEqual(firstGroup.0.name, "Workout A")
            XCTAssertEqual(firstGroup.1.count, 2)
        }
    }
    
    // MARK: - Test Search Functionality
    
    func testPerformSearch() async {
        // Given
        let searchTerm = "run"
        let exercise = createMockExercise(name: "Morning Run", startDate: Date(), repeatDays: [])
        let workout = createMockWorkout(name: "Running Workout", exercises: [exercise])
        
        let searchResult = SearchResult(
            workout: workout,
            exercises: [exercise],
            tags: [],
            findReasons: [.workout]
        )
        
        mockRepository.mockSearchResults = [searchResult]
        
        // When
        await viewModel.performSearch(term: searchTerm)
        
        // Then
        XCTAssertEqual(viewModel.searchResults.count, 1)
        XCTAssertEqual(viewModel.searchResults.first?.workout.name, "Running Workout")
    }
    
    func testPerformSearchEmptyTerm() async {
        // Given
        let emptyTerm = ""
        
        // When
        await viewModel.performSearch(term: emptyTerm)
        
        // Then
        XCTAssertTrue(viewModel.searchResults.isEmpty, "Empty search term should return no results")
    }
    
    // MARK: - Test Stopwatch Data
    
    func testStopwatchDataFor() {
        // Given
        let testDate = Date()
        let exerciseId = UUID()
        
        let stopwatchData = StopwatchData(
            completionDate: testDate,
            exerciseId: exerciseId,
            times: [Time(start: testDate, end: testDate.addingTimeInterval(300))]
        )
        
        viewModel.stopwatchData = [stopwatchData]
        
        // When
        let foundData = viewModel.stopwatchDataFor(exerciseId: exerciseId, on: testDate)
        
        // Then
        XCTAssertNotNil(foundData)
        XCTAssertEqual(foundData?.exerciseId, exerciseId)
    }
    
    func testStopwatchDataForDifferentDate() {
        // Given
        let testDate = Date()
        let differentDate = Calendar.current.date(byAdding: .day, value: 1, to: testDate)!
        let exerciseId = UUID()
        
        let stopwatchData = StopwatchData(
            completionDate: testDate,
            exerciseId: exerciseId,
            times: [Time(start: testDate, end: testDate.addingTimeInterval(300))]
        )
        
        viewModel.stopwatchData = [stopwatchData]
        
        // When
        let foundData = viewModel.stopwatchDataFor(exerciseId: exerciseId, on: differentDate)
        
        // Then
        XCTAssertNil(foundData, "Should not find data for different date")
    }
    
    // MARK: - Test Style Toggle
    
    func testToggleStyle() {
        // Given
        let initialStyle = viewModel.styleIdx
        
        // When
        viewModel.toggleStyle()
        
        // Then
        XCTAssertNotEqual(viewModel.styleIdx, initialStyle, "Style should change")
        XCTAssertTrue(viewModel.styleIdx == 0 || viewModel.styleIdx == 1, "Style should be 0 or 1")
    }
    
    // MARK: - Test Popover Controls
    
    func testTogglePopover() {
        // Given
        let initialState = viewModel.isShowingPopover
        
        // When
        viewModel.togglePopover()
        
        // Then
        XCTAssertNotEqual(viewModel.isShowingPopover, initialState, "Popover state should toggle")
    }
    
    func testClosePopover() {
        // Given
        viewModel.isShowingPopover = true
        viewModel.searchTerm = "test search"
        
        // When
        viewModel.closePopover()
        
        // Then
        XCTAssertFalse(viewModel.isShowingPopover, "Popover should be closed")
        XCTAssertTrue(viewModel.searchTerm.isEmpty, "Search term should be cleared")
    }
    
    // MARK: - Helper Methods
    
    private func createMockExercise(name: String, startDate: Date, repeatDays: Set<DayOfWeek>) -> Exercise {
        return Exercise(
            name: name,
            tags: [],
            startDate: startDate,
            priority: 2,
            repeatDays: repeatDays
        )
    }
    
    private func createMockWorkout(name: String, exercises: [Exercise]) -> Workout {
        return Workout(
            name: name,
            exercises: exercises,
            startDate: Date(),
            priority: 2
        )
    }
}
