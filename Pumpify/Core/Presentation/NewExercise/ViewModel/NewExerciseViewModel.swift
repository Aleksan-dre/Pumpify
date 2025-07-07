//
//  NewExerciseViewModel.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 07.07.25.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
final class NewExerciseViewModel: BaseViewModel {
    @Published var name: String = ""
    @Published var startDate: Date = .now
    @Published var priority: Int = 2
    @Published var tags: [String] = []
    @Published var repeatDays = Set<DayOfWeek>()
    @Published var showNewTagPopup = false
    @Published var isFormValid: Bool = false
    @Published var settings: Settings?
    
    private let workout: Workout
    
    init(workout: Workout, repository: any DataRepositoryProtocol) {
        self.workout = workout
        super.init(repository: repository)
        
        // Setup form validation
        $name
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .assign(to: &$isFormValid)
        
        Task {
            await loadSettings()
        }
    }
    
    @MainActor
    func loadSettings() async {
        await withErrorHandling {
            self.settings = try await self.repository.fetchSettings()
        }
    }
    
    @MainActor
    func saveExercise() async -> Bool {
        guard isFormValid else { return false }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return false }
        
        // Check if exercise with same name already exists in workout
        if workout.exercises.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            return false
        }
        
        let exercise = Exercise(
            name: trimmedName,
            tags: tags,
            startDate: startDate,
            priority: priority,
            repeatDays: repeatDays
        )
        
        return await withErrorHandling {
            try await self.repository.saveExercise(exercise, to: self.workout)
            return true
        } ?? false
    }
    
    @MainActor
    func addTag(_ tag: String) {
        let trimmedTag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTag.isEmpty && !tags.contains(trimmedTag) else { return }
        tags.append(trimmedTag)
    }
    
    @MainActor
    func removeTag(at offsets: IndexSet) {
        tags.remove(atOffsets: offsets)
    }
    
    @MainActor
    func toggleTagPopup() {
        showNewTagPopup.toggle()
    }
    
    @MainActor
    func resetForm() {
        name = ""
        startDate = .now
        priority = 2
        tags = []
        repeatDays = Set<DayOfWeek>()
    }
}
