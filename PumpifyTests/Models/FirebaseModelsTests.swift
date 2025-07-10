//
//  FirebaseModelsTests.swift
//  PumpifyTests
//
//  Created by Aleksandre Shalikashvili on 11.07.25.
//

import XCTest
@testable import Pumpify

final class FirebaseModelsTests: XCTestCase {
    
    // MARK: - Test FirebaseWorkout Conversion
    
    func testFirebaseWorkoutToSwiftDataConversion() {
        // Given
        let firebaseExercise = FirebaseExercise(
            id: UUID().uuidString,
            name: "Push-ups",
            tags: ["strength", "bodyweight"],
            startDate: Date(),
            priority: 3,
            repeatDays: [.monday, .wednesday, .friday],
            workoutId: UUID().uuidString,
            userId: "test-user-id"
        )
        
        let firebaseWorkout = FirebaseWorkout(
            id: UUID().uuidString,
            name: "Morning Workout",
            exercises: [firebaseExercise],
            startDate: Date(),
            priority: 2,
            userId: "test-user-id"
        )
        
        // When
        let swiftDataWorkout = firebaseWorkout.toSwiftData()
        
        // Then
        XCTAssertEqual(swiftDataWorkout.name, "Morning Workout")
        XCTAssertEqual(swiftDataWorkout.priority, 2)
        XCTAssertEqual(swiftDataWorkout.exercises.count, 1)
        
        if let exercise = swiftDataWorkout.exercises.first {
            XCTAssertEqual(exercise.name, "Push-ups")
            XCTAssertEqual(exercise.tags, ["strength", "bodyweight"])
            XCTAssertEqual(exercise.priority, 3)
            XCTAssertEqual(exercise.repeatDays, [.monday, .wednesday, .friday])
        }
    }
    
    func testSwiftDataWorkoutToFirebaseConversion() {
        // Given
        let exercise = Exercise(
            name: "Squats",
            tags: ["legs", "strength"],
            startDate: Date(),
            priority: 2,
            repeatDays: [.tuesday, .thursday]
        )
        
        let workout = Workout(
            name: "Leg Day",
            exercises: [exercise],
            startDate: Date(),
            priority: 1
        )
        
        let userId = "test-user-id"
        
        // When
        let firebaseWorkout = FirebaseWorkout.fromSwiftData(workout, userId: userId)
        
        // Then
        XCTAssertEqual(firebaseWorkout.name, "Leg Day")
        XCTAssertEqual(firebaseWorkout.priority, 1)
        XCTAssertEqual(firebaseWorkout.userId, userId)
        XCTAssertEqual(firebaseWorkout.exercises.count, 1)
        
        if let firebaseExercise = firebaseWorkout.exercises.first {
            XCTAssertEqual(firebaseExercise.name, "Squats")
            XCTAssertEqual(firebaseExercise.tags, ["legs", "strength"])
            XCTAssertEqual(firebaseExercise.priority, 2)
            XCTAssertEqual(firebaseExercise.repeatDays, [.tuesday, .thursday])
            XCTAssertEqual(firebaseExercise.userId, userId)
        }
    }
    
    // MARK: - Test FirebaseSettings Conversion
    
    func testFirebaseSettingsToSwiftDataConversion() {
        // Given
        let firebaseTag = FirebaseTag(name: "cardio", userId: "test-user-id")
        let firebaseSettings = FirebaseSettings(
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            birthday: Date(),
            accentColor: .blue,
            availableTags: [firebaseTag],
            notificationTime: HourAndMinute(hour: 9, minute: 30),
            dynamicFontSize: 16.0,
            hasAccessedSettings: true,
            userId: "test-user-id"
        )
        
        // When
        let swiftDataSettings = firebaseSettings.toSwiftData()
        
        // Then
        XCTAssertEqual(swiftDataSettings.firstName, "John")
        XCTAssertEqual(swiftDataSettings.lastName, "Doe")
        XCTAssertEqual(swiftDataSettings.email, "john.doe@example.com")
        XCTAssertEqual(swiftDataSettings.accentColor, .blue)
        XCTAssertEqual(swiftDataSettings.notificationTime?.hour, 9)
        XCTAssertEqual(swiftDataSettings.notificationTime?.minute, 30)
        XCTAssertEqual(swiftDataSettings.dynamicFontSize, 16.0)
        XCTAssertEqual(swiftDataSettings.hasAccessedSettings, true)
        XCTAssertEqual(swiftDataSettings.availableTags.count, 1)
        XCTAssertEqual(swiftDataSettings.availableTags.first?.name, "cardio")
    }
    
    func testSwiftDataSettingsToFirebaseConversion() {
        // Given
        let tag = Tag(name: "yoga")
        let settings = Settings()
        settings.firstName = "Jane"
        settings.lastName = "Smith"
        settings.email = "jane.smith@example.com"
        settings.accentColor = .purple
        settings.availableTags = [tag]
        settings.notificationTime = HourAndMinute(hour: 7, minute: 0)
        settings.dynamicFontSize = 18.0
        settings.hasAccessedSettings = false
        
        let userId = "test-user-id"
        
        // When
        let firebaseSettings = FirebaseSettings.fromSwiftData(settings, userId: userId)
        
        // Then
        XCTAssertEqual(firebaseSettings.firstName, "Jane")
        XCTAssertEqual(firebaseSettings.lastName, "Smith")
        XCTAssertEqual(firebaseSettings.email, "jane.smith@example.com")
        XCTAssertEqual(firebaseSettings.accentColor, .purple)
        XCTAssertEqual(firebaseSettings.notificationTime?.hour, 7)
        XCTAssertEqual(firebaseSettings.notificationTime?.minute, 0)
        XCTAssertEqual(firebaseSettings.dynamicFontSize, 18.0)
        XCTAssertEqual(firebaseSettings.hasAccessedSettings, false)
        XCTAssertEqual(firebaseSettings.userId, userId)
        XCTAssertEqual(firebaseSettings.availableTags.count, 1)
        XCTAssertEqual(firebaseSettings.availableTags.first?.name, "yoga")
    }
    
    // MARK: - Test FirebaseStopwatchData Conversion
    
    func testFirebaseStopwatchDataToSwiftDataConversion() {
        // Given
        let firebaseTime = FirebaseTime(
            start: Date(),
            end: Date().addingTimeInterval(300) // 5 minutes later
        )
        
        let firebaseStopwatchData = FirebaseStopwatchData(
            completionDate: Date(),
            exerciseId: UUID().uuidString,
            times: [firebaseTime],
            userId: "test-user-id"
        )
        
        // When
        let swiftDataStopwatchData = firebaseStopwatchData.toSwiftData()
        
        // Then
        XCTAssertEqual(swiftDataStopwatchData.times.count, 1)
        XCTAssertEqual(swiftDataStopwatchData.totalInterval, 300, accuracy: 1.0)
        
        if let time = swiftDataStopwatchData.times.first {
            XCTAssertEqual(time.interval, 300, accuracy: 1.0)
        }
    }
    
    func testSwiftDataStopwatchDataToFirebaseConversion() {
        // Given
        let time = Time(
            start: Date(),
            end: Date().addingTimeInterval(600) // 10 minutes later
        )
        
        let stopwatchData = StopwatchData(
            completionDate: Date(),
            exerciseId: UUID(),
            times: [time]
        )
        
        let userId = "test-user-id"
        
        // When
        let firebaseStopwatchData = FirebaseStopwatchData.fromSwiftData(stopwatchData, userId: userId)
        
        // Then
        XCTAssertEqual(firebaseStopwatchData.userId, userId)
        XCTAssertEqual(firebaseStopwatchData.times.count, 1)
        XCTAssertEqual(firebaseStopwatchData.totalInterval, 600, accuracy: 1.0)
        
        if let firebaseTime = firebaseStopwatchData.times.first {
            XCTAssertEqual(firebaseTime.interval, 600, accuracy: 1.0)
        }
    }
    
    // MARK: - Test Total Interval Calculations
    
    func testFirebaseStopwatchDataTotalInterval() {
        // Given
        let time1 = FirebaseTime(
            start: Date(),
            end: Date().addingTimeInterval(300) // 5 minutes
        )
        
        let time2 = FirebaseTime(
            start: Date(),
            end: Date().addingTimeInterval(180) // 3 minutes
        )
        
        let firebaseStopwatchData = FirebaseStopwatchData(
            completionDate: Date(),
            exerciseId: UUID().uuidString,
            times: [time1, time2],
            userId: "test-user-id"
        )
        
        // When
        let totalInterval = firebaseStopwatchData.totalInterval
        
        // Then
        XCTAssertEqual(totalInterval, 480, accuracy: 1.0) // 5 + 3 = 8 minutes
    }
    
    func testFirebaseTimeTotalInterval() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(450) // 7.5 minutes
        
        let firebaseTime = FirebaseTime(start: startDate, end: endDate)
        
        // When
        let interval = firebaseTime.interval
        
        // Then
        XCTAssertEqual(interval, 450, accuracy: 1.0)
    }
    
    // MARK: - Test Edge Cases
    
    func testConversionWithEmptyArrays() {
        // Given
        let firebaseWorkout = FirebaseWorkout(
            name: "Empty Workout",
            exercises: [], // Empty exercises
            startDate: Date(),
            userId: "test-user-id"
        )
        
        // When
        let swiftDataWorkout = firebaseWorkout.toSwiftData()
        
        // Then
        XCTAssertTrue(swiftDataWorkout.exercises.isEmpty)
        XCTAssertEqual(swiftDataWorkout.name, "Empty Workout")
    }
    
    func testConversionWithNilValues() {
        // Given
        let firebaseSettings = FirebaseSettings(
            firstName: nil,
            lastName: nil,
            email: nil,
            birthday: nil,
            notificationTime: nil,
            dynamicFontSize: nil,
            userId: "test-user-id"
        )
        
        // When
        let swiftDataSettings = firebaseSettings.toSwiftData()
        
        // Then
        XCTAssertNil(swiftDataSettings.firstName)
        XCTAssertNil(swiftDataSettings.lastName)
        XCTAssertNil(swiftDataSettings.email)
        XCTAssertNil(swiftDataSettings.birthday)
        XCTAssertNil(swiftDataSettings.notificationTime)
        XCTAssertNil(swiftDataSettings.dynamicFontSize)
        XCTAssertEqual(swiftDataSettings.accentColor, .yellow) // Default value
    }
}
