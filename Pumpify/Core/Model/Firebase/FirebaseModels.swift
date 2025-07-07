//
//  FirebaseWorkout.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 06.07.25.
//

import Foundation
import SwiftUI

// MARK: - Firebase-compatible models
struct FirebaseWorkout: Codable, Identifiable {
    let id: String
    let name: String
    let exercises: [FirebaseExercise]
    let startDate: Date
    let priority: Int
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        name: String,
        exercises: [FirebaseExercise] = [],
        startDate: Date,
        priority: Int = 2,
        userId: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.exercises = exercises
        self.startDate = startDate
        self.priority = priority
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct FirebaseExercise: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let tags: [String]
    let startDate: Date
    let priority: Int
    let repeatDays: Set<DayOfWeek>
    let workoutId: String
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        name: String,
        tags: [String] = [],
        startDate: Date,
        priority: Int = 2,
        repeatDays: Set<DayOfWeek> = Set(),
        workoutId: String,
        userId: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.tags = tags
        self.startDate = startDate
        self.priority = priority
        self.repeatDays = repeatDays
        self.workoutId = workoutId
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct FirebaseStopwatchData: Codable, Identifiable {
    let id: String
    let completionDate: Date
    let times: [FirebaseTime]
    let exerciseId: String
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        completionDate: Date,
        exerciseId: String,
        times: [FirebaseTime],
        userId: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.completionDate = completionDate
        self.times = times
        self.exerciseId = exerciseId
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var totalInterval: TimeInterval {
        times.lazy.map { $0.interval }.reduce(.zero, +)
    }
}

struct FirebaseTime: Codable, Identifiable {
    let id: String
    let start: Date
    let end: Date
    
    init(
        id: String = UUID().uuidString,
        start: Date,
        end: Date
    ) {
        self.id = id
        self.start = start
        self.end = end
    }
    
    var interval: TimeInterval {
        start.distance(to: end)
    }
}

struct FirebaseSettings: Codable, Identifiable {
    let id: String
    let firstName: String?
    let lastName: String?
    let email: String?
    let birthday: Date?
    let accentColor: AccentColor
    let availableTags: [FirebaseTag]
    let notificationTime: HourAndMinute?
    let dynamicFontSize: Double?
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        firstName: String? = nil,
        lastName: String? = nil,
        email: String? = nil,
        birthday: Date? = nil,
        accentColor: AccentColor = .yellow,
        availableTags: [FirebaseTag] = [],
        notificationTime: HourAndMinute? = nil,
        dynamicFontSize: Double? = 14,
        userId: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.birthday = birthday
        self.accentColor = accentColor
        self.availableTags = availableTags
        self.notificationTime = notificationTime
        self.dynamicFontSize = dynamicFontSize
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct FirebaseTag: Codable, Identifiable {
    let id: String
    let name: String
    let userId: String
    let createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        name: String,
        userId: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.userId = userId
        self.createdAt = createdAt
    }
}

// MARK: - Conversion Extensions
extension FirebaseWorkout {
    func toSwiftData() -> Workout {
        let workout = Workout(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            exercises: exercises.map { $0.toSwiftData() },
            startDate: startDate,
            priority: priority
        )
        return workout
    }
    
    static func fromSwiftData(_ workout: Workout, userId: String) -> FirebaseWorkout {
        return FirebaseWorkout(
            id: workout.id.uuidString,
            name: workout.name,
            exercises: workout.exercises.map { FirebaseExercise.fromSwiftData($0, workoutId: workout.id.uuidString, userId: userId) },
            startDate: workout.startDate,
            priority: workout.priority,
            userId: userId
        )
    }
}

extension FirebaseExercise {
    func toSwiftData() -> Exercise {
        return Exercise(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            tags: tags,
            startDate: startDate,
            priority: priority,
            repeatDays: repeatDays
        )
    }
    
    static func fromSwiftData(_ exercise: Exercise, workoutId: String, userId: String) -> FirebaseExercise {
        return FirebaseExercise(
            id: exercise.id.uuidString,
            name: exercise.name,
            tags: exercise.tags,
            startDate: exercise.startDate,
            priority: exercise.priority,
            repeatDays: exercise.repeatDays,
            workoutId: workoutId,
            userId: userId
        )
    }
}

extension FirebaseStopwatchData {
    func toSwiftData() -> StopwatchData {
        return StopwatchData(
            completionDate: completionDate,
            exerciseId: UUID(uuidString: exerciseId) ?? UUID(),
            times: times.map { $0.toSwiftData() }
        )
    }
    
    static func fromSwiftData(_ stopwatchData: StopwatchData, userId: String) -> FirebaseStopwatchData {
        return FirebaseStopwatchData(
            completionDate: stopwatchData.completionDate,
            exerciseId: stopwatchData.exerciseId.uuidString,
            times: stopwatchData.times.map { FirebaseTime.fromSwiftData($0) },
            userId: userId
        )
    }
}

extension FirebaseTime {
    func toSwiftData() -> Time {
        return Time(start: start, end: end)
    }
    
    static func fromSwiftData(_ time: Time) -> FirebaseTime {
        return FirebaseTime(
            start: time.start,
            end: time.end
        )
    }
}

extension FirebaseSettings {
    func toSwiftData() -> Settings {
        let settings = Settings()
        settings.firstName = firstName
        settings.lastName = lastName
        settings.email = email
        settings.birthday = birthday
        settings.accentColor = accentColor
        settings.availableTags = availableTags.map { $0.toSwiftData() }
        settings.notificationTime = notificationTime
        settings.dynamicFontSize = dynamicFontSize.map { CGFloat($0) }
        return settings
    }
    
    static func fromSwiftData(_ settings: Settings, userId: String) -> FirebaseSettings {
        return FirebaseSettings(
            firstName: settings.firstName,
            lastName: settings.lastName,
            email: settings.email,
            birthday: settings.birthday,
            accentColor: settings.accentColor,
            availableTags: settings.availableTags.map { FirebaseTag.fromSwiftData($0, userId: userId) },
            notificationTime: settings.notificationTime,
            dynamicFontSize: settings.dynamicFontSize.map { Double($0) },
            userId: userId
        )
    }
}

extension FirebaseTag {
    func toSwiftData() -> Tag {
        return Tag(name: name)
    }
    
    static func fromSwiftData(_ tag: Tag, userId: String) -> FirebaseTag {
        return FirebaseTag(
            name: tag.name,
            userId: userId
        )
    }
}
