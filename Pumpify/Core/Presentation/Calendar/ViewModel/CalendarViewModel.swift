//
//  CalendarViewModel.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 06.07.25.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
final class CalendarViewModel: BaseViewModel {
    @Published var currentMonth = Date()
    @Published var styleIdx: Int = 0
    @Published var searchTerm: String = ""
    @Published var isShowingPopover = false
    @Published var workouts: [Workout] = []
    @Published var stopwatchData: [StopwatchData] = []
    @Published var availableTags: [Tag] = []
    @Published var searchResults: [SearchResult] = []
    
    private let calendar = Calendar.current
    
    var daysOfWeek: [DayOfWeek] {
        [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }
    
    var tags: [Tag] {
        availableTags
    }
    
    var exerciseInMonth: [(Date, [Exercise])] {
        dayInMonth.compactMap { date in
            let exercises = exercisesInDay(date: date)
            return exercises.isEmpty ? nil : (date, exercises)
        }
    }
    
    var dayInMonth: [Date] {
        (1...daysInMonth(date: currentMonth)).compactMap { day in
            Date.from(
                year: calendar.dateComponents([.year], from: currentMonth).year!,
                month: calendar.dateComponents([.month], from: currentMonth).month!,
                day: day
            )
        }
    }
    
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
            await loadData()
        }
    }
    
    @MainActor
    func loadData() async {
        await loadWorkouts()
        await loadStopwatchData()
        await loadSettings()
    }
    
    @MainActor
    func loadWorkouts() async {
        await withErrorHandling {
            self.workouts = try await self.repository.fetchWorkouts()
        }
    }
    
    @MainActor
    func loadStopwatchData() async {
        await withErrorHandling {
            self.stopwatchData = try await self.repository.fetchAllStopwatchData()
        }
    }
    
    @MainActor
    func loadSettings() async {
        await withErrorHandling {
            if let settings = try await self.repository.fetchSettings() {
                self.availableTags = settings.availableTags
            }
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
    
    func changeMonth(by amount: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: amount, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    func daysInMonth(date: Date) -> Int {
        calendar.range(of: .day, in: .month, for: date)?.count ?? 0
    }
    
    func numberOfEmptyCells(at date: Date) -> Int {
        let firstDay = calendar.dateInterval(of: .month, for: date)?.start ?? date
        let weekday = calendar.component(.weekday, from: firstDay)
        return (weekday + 5) % 7
    }
    
    func exercisesInDay(date: Date) -> [Exercise] {
        let allExercises = workouts.flatMap { $0.exercises }
        let componentsOfDate = calendar.dateComponents([.day, .month, .year], from: date)
        
        return allExercises.filter { exercise in
            if exercise.startDate > calendar.date(byAdding: .day, value: 1, to: date)! {
                return false
            }
            
            let componentsOfExercise = calendar.dateComponents([.day, .month, .year], from: exercise.startDate)
            if componentsOfDate == componentsOfExercise {
                return true
            }
            
            var weekdayOfDate = (calendar.dateComponents([.weekday], from: date).weekday! + 6) % 7
            if weekdayOfDate == 0 { weekdayOfDate = 7 }
            let weekday = DayOfWeek(rawValue: weekdayOfDate)!
            return exercise.repeatDays.contains(weekday)
        }
    }
    
    func exercisesForDate(_ date: Date) -> [Exercise] {
        return exercisesInDay(date: date)
    }
    
    func stopwatchDataFor(exerciseId: UUID, on date: Date) -> StopwatchData? {
        return stopwatchData.first { data in
            data.exerciseId == exerciseId && calendar.isDate(data.completionDate, inSameDayAs: date)
        }
    }
    
    func togglePopover() {
        isShowingPopover.toggle()
    }
    
    func closePopover() {
        isShowingPopover = false
        searchTerm = ""
    }
    
    func toggleStyle() {
        styleIdx = (styleIdx + 1) % 2
    }
    
    func exercisesInMonth() -> [(Date, [Exercise])] {
        return exerciseInMonth
    }
    
    @MainActor
    func refreshData() async {
        await withErrorHandling {
            try await self.repository.forceRefreshData()
            await self.loadData()
        }
    }
}
