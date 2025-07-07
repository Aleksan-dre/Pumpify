//
//  WorkoutsViewModel.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 28.06.25.
//

import SwiftUI
import SwiftData

@MainActor
final class WorkoutsViewModel: BaseViewModel {
    @Published var searchTerm: String = ""
    @Published var isSearching: Bool = false
    @Published var workouts: [Workout] = []
    @Published var searchResults: [SearchResult] = []
    
    override init(repository: any DataRepositoryProtocol) {
        super.init(repository: repository)
        
        // Setup search functionality
        $searchTerm
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] term in
                Task {
                    await self?.performSearch(term: term)
                }
            }
            .store(in: &cancellables)
        
        Task {
            await loadExercises()
        }
    }
    
    @MainActor
    func loadExercises() async {
        await withErrorHandling {
            self.workouts = try await self.repository.fetchWorkouts()
        }
    }
    
    @MainActor
    func performSearch(term: String) async {
        guard !term.isEmpty else {
            searchResults = []
            return
        }
        
        await withErrorHandling {
            self.searchResults = try await self.repository.searchWorkouts(term: term)
        }
    }
    
    @MainActor
    func delete(at offsets: IndexSet) async {
        await withErrorHandling {
            for index in offsets {
                let workout = self.workouts[index]
                
                // Delete all related stopwatch data
                let allStopwatchData = try await self.repository.fetchAllStopwatchData()
                for exercise in workout.exercises {
                    let relatedStopwatchData = allStopwatchData.filter { $0.exerciseId == exercise.id }
                    for data in relatedStopwatchData {
                        try await self.repository.deleteStopwatchData(data)
                    }
                }
                
                // Delete the workout
                try await self.repository.deleteWorkout(workout)
            }
            
            // Reload the workouts
            await self.loadExercises()
        }
    }
    
    @MainActor
    func refreshData() async {
        await withErrorHandling {
            try await self.repository.forceRefreshData()
            await self.loadExercises()
        }
    }
}
