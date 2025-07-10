//
//  HomeViewModel.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 27.06.25.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
final class HomeViewModel: BaseViewModel {
    @Published var todayExercises: [Exercise] = []
    @Published var stopwatchData: [StopwatchData] = []
    
    override init(repository: any DataRepositoryProtocol) {
        super.init(repository: repository)
        
        Task {
            await loadInitialData()
        }
    }
    
    @MainActor
    func loadInitialData() async {
        await loadTodayExercises()
        await loadStopwatchData()
    }
    
    @MainActor
    func loadTodayExercises() async {
        await withErrorHandling {
            self.todayExercises = try await self.repository.fetchExercisesForDate(Date())
        }
    }
    
    @MainActor
    func loadStopwatchData() async {
        await withErrorHandling {
            self.stopwatchData = try await self.repository.fetchAllStopwatchData()
        }
    }
    
    @MainActor
    func refreshData() async {
        await withErrorHandling {
            try await self.repository.forceRefreshData()
            await self.loadInitialData()
        }
    }
}
