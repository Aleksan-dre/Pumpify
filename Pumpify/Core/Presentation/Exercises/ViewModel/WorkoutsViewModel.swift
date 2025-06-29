//
//  WorkoutsViewModel.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 28.06.25.
//

import SwiftUI
import SwiftData

@MainActor
final class WorkoutsViewModel: ObservableObject {
    @Published var searchTerm: String = ""
    @Published var isSearching: Bool = false
    @Published var workouts: [Workout] = []

    private let context: ModelContext
    private var allExercises: [Workout] = []

    init(context: ModelContext) {
        self.context = context
    }
    
    var searchResults: [SearchResult] {
        guard !searchTerm.isEmpty else { return [] }

        let term = searchTerm.lowercased()
        var result: [Workout: SearchResult] = [:]

        for workout in allExercises {
            if workout.name.lowercased().contains(term) {
                result[workout] = SearchResult(
                    workout: workout,
                    exercises: [],
                    tags: [],
                    findReasons: [.workout]
                )
            }
            for exercise in workout.exercises {
                if exercise.name.lowercased().contains(term) {
                    var sr = result[workout] ?? SearchResult(
                        workout: workout,
                        exercises: [],
                        tags: [],
                        findReasons: []
                    )
                    sr.exercises.insert(exercise)
                    sr.findReasons.insert(.exercise(exercise.id))
                    result[workout] = sr
                }
                for tag in exercise.tags where tag.lowercased().contains(term) {
                    var sr = result[workout] ?? SearchResult(
                        workout: workout,
                        exercises: [],
                        tags: [],
                        findReasons: []
                    )
                    sr.exercises.insert(exercise)
                    sr.tags.insert(tag)
                    sr.findReasons.insert(.tag(tag))
                    result[workout] = sr
                }
            }
        }

        return Array(result.values)
    }

    func loadExercises() async {
        do {
            let descriptor = FetchDescriptor<Workout>(
                sortBy: [
                    SortDescriptor(\Workout.priority, order: .reverse),
                    SortDescriptor(\Workout.name)
                ]
            )
            let fetched = try context.fetch(descriptor)
            await MainActor.run {
                self.allExercises = fetched
                self.workouts = fetched
            }
        } catch {
            print("Failed to fetch workouts: \(error)")
        }
    }

    func delete(at offsets: IndexSet) {
        for index in offsets {
            let workout = workouts[index]
            for exercise in workout.exercises {
                if let stopwatchData = try? context.fetch(FetchDescriptor<StopwatchData>()) {
                    stopwatchData.filter { $0.exerciseId == exercise.id }.forEach { context.delete($0) }
                }
                context.delete(exercise)
            }
            context.delete(workout)
        }
    }
}
