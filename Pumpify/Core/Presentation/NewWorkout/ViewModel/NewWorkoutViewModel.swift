//
//  NewWorkoutViewModel.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 07.07.25.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
final class NewWorkoutViewModel: BaseViewModel {
    @Published var name: String = ""
    @Published var startDate: Date = .now
    @Published var priority: Int = 2
    @Published var isFormValid: Bool = false
    @Published var settings: Settings?
    
    override init(repository: any DataRepositoryProtocol) {
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
    func saveWorkout() async -> Bool {
        guard isFormValid else { return false }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return false }
        
        let workout = Workout(
            name: trimmedName,
            startDate: startDate,
            priority: priority
        )
        
        return await withErrorHandling {
            try await self.repository.saveWorkout(workout)
            return true
        } ?? false
    }
    
    @MainActor
    func resetForm() {
        name = ""
        startDate = .now
        priority = 2
    }
}
