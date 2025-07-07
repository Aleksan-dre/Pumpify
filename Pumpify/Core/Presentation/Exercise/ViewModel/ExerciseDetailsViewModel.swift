//
//  ExerciseDetailsViewModel.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 07.07.25.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
final class ExerciseDetailsViewModel: BaseViewModel {
    @Published var exercises: [Exercise] = []
    @Published var stopwatchData: [StopwatchData] = []
    @Published var showRestartStopwatchConfirmation = false
    @Published var navigatingToStopwatch = false
    @Published var continuingStopwatchDatum: StopwatchData?
    
    private let date: Date
    
    init(date: Date, repository: any DataRepositoryProtocol) {
        self.date = date
        super.init(repository: repository)
        
        Task {
            await loadData()
        }
    }
    
    @MainActor
    func loadData() async {
        await loadExercises()
        await loadStopwatchData()
    }
    
    @MainActor
    func loadExercises() async {
        await withErrorHandling {
            self.exercises = try await self.repository.fetchExercisesForDate(self.date)
        }
    }
    
    @MainActor
    func loadStopwatchData() async {
        await withErrorHandling {
            self.stopwatchData = try await self.repository.fetchAllStopwatchData()
        }
    }
    
    func getStopwatchData(for exercise: Exercise) -> StopwatchData? {
        return stopwatchData.first { data in
            data.exerciseId == exercise.id && Calendar.current.isDate(data.completionDate, inSameDayAs: date)
        }
    }
    
    func hasStopwatchData(for exercise: Exercise) -> Bool {
        return getStopwatchData(for: exercise) != nil
    }
    
    @MainActor
    func refreshData() async {
        await withErrorHandling {
            try await self.repository.forceRefreshData()
            await self.loadData()
        }
    }
    
    @MainActor
    func handleStopwatchNavigation(for exercise: Exercise) {
        let existingData = getStopwatchData(for: exercise)
        if let existingData = existingData {
            continuingStopwatchDatum = existingData
            showRestartStopwatchConfirmation = true
        } else {
            continuingStopwatchDatum = nil
            navigatingToStopwatch = true
        }
    }
    
    @MainActor
    func confirmRestartStopwatch() {
        showRestartStopwatchConfirmation = false
        navigatingToStopwatch = true
    }
    
    @MainActor
    func cancelRestartStopwatch() {
        showRestartStopwatchConfirmation = false
        continuingStopwatchDatum = nil
    }
}
