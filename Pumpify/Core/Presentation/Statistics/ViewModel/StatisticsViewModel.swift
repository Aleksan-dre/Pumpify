//
//  StatisticsViewModel.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 11.07.2025.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
final class StatisticsViewModel: BaseViewModel {
    @Published var stopwatchData: [StopwatchData] = []
    @Published var exercises: [Exercise] = []
    @Published var selectedPeriod: StatisticsPeriod = .week
    @Published var selectedDate = Date()
    
    // Computed statistics
    @Published var totalTimeThisPeriod: TimeInterval = 0
    @Published var completedExercisesThisPeriod: Int = 0
    @Published var averageTimePerDay: TimeInterval = 0
    @Published var mostActiveDay: String = ""
    @Published var topExercises: [(exercise: Exercise, totalTime: TimeInterval)] = []
    @Published var dailyProgress: [(date: Date, totalTime: TimeInterval)] = []
    @Published var weeklyComparison: [(week: String, totalTime: TimeInterval)] = []
    
    private let calendar = Calendar.current
    
    override init(repository: any DataRepositoryProtocol) {
        super.init(repository: repository)
        
        // React to period or date changes
        Publishers.CombineLatest($selectedPeriod, $selectedDate)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _, _ in
                Task {
                    await self?.calculateStatistics()
                }
            }
            .store(in: &cancellables)
        
        Task {
            await loadData()
        }
    }
    
    @MainActor
    func loadData() async {
        await loadStopwatchData()
        await loadExercises()
        await calculateStatistics()
    }
    
    @MainActor
    func loadStopwatchData() async {
        await withErrorHandling {
            self.stopwatchData = try await self.repository.fetchAllStopwatchData()
        }
    }
    
    @MainActor
    func loadExercises() async {
        await withErrorHandling {
            let workouts = try await self.repository.fetchWorkouts()
            self.exercises = workouts.flatMap { $0.exercises }
        }
    }
    
    @MainActor
    func refreshData() async {
        await withErrorHandling {
            try await self.repository.forceRefreshData()
            await self.loadData()
        }
    }
    
    @MainActor
    func calculateStatistics() async {
        let periodData = getStopwatchDataForPeriod()
        
        // Total time for period
        totalTimeThisPeriod = periodData.reduce(0) { $0 + $1.totalInterval }
        
        // Completed exercises count
        completedExercisesThisPeriod = Set(periodData.map { $0.exerciseId }).count
        
        // Average time per day
        let daysInPeriod = getDaysInPeriod()
        averageTimePerDay = daysInPeriod > 0 ? totalTimeThisPeriod / Double(daysInPeriod) : 0
        
        // Most active day
        mostActiveDay = findMostActiveDay(from: periodData)
        
        // Top exercises by total time
        topExercises = calculateTopExercises(from: periodData)
        
        // Daily progress for charts
        dailyProgress = calculateDailyProgress(from: periodData)
        
        // Weekly comparison (for trends)
        weeklyComparison = calculateWeeklyComparison()
    }
    
    private func getStopwatchDataForPeriod() -> [StopwatchData] {
        let (startDate, endDate) = getPeriodRange()
        
        return stopwatchData.filter { data in
            data.completionDate >= startDate && data.completionDate <= endDate
        }
    }
    
    private func getPeriodRange() -> (start: Date, end: Date) {
        let endDate = calendar.startOfDay(for: selectedDate)
        let startDate: Date
        
        switch selectedPeriod {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -6, to: endDate) ?? endDate
        case .month:
            startDate = calendar.date(byAdding: .day, value: -29, to: endDate) ?? endDate
        case .threeMonths:
            startDate = calendar.date(byAdding: .day, value: -89, to: endDate) ?? endDate
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: endDate) ?? endDate
        }
        
        // End date should be end of selected day
        let adjustedEndDate = calendar.date(byAdding: .day, value: 1, to: endDate) ?? endDate
        
        return (startDate, adjustedEndDate)
    }
    
    private func getDaysInPeriod() -> Int {
        switch selectedPeriod {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        case .year: return 365
        }
    }
    
    private func findMostActiveDay(from data: [StopwatchData]) -> String {
        var dayTotals: [String: TimeInterval] = [:]
        
        for stopwatchData in data {
            let dayName = DateFormatter.dayOfWeek.string(from: stopwatchData.completionDate)
            dayTotals[dayName, default: 0] += stopwatchData.totalInterval
        }
        
        let mostActive = dayTotals.max { $0.value < $1.value }
        return mostActive?.key ?? "No data"
    }
    
    private func calculateTopExercises(from data: [StopwatchData]) -> [(exercise: Exercise, totalTime: TimeInterval)] {
        var exerciseTotals: [UUID: TimeInterval] = [:]
        
        for stopwatchData in data {
            exerciseTotals[stopwatchData.exerciseId, default: 0] += stopwatchData.totalInterval
        }
        
        let topExerciseIds = exerciseTotals.sorted { $0.value > $1.value }.prefix(5)
        
        return topExerciseIds.compactMap { (exerciseId, totalTime) in
            guard let exercise = exercises.first(where: { $0.id == exerciseId }) else { return nil }
            return (exercise: exercise, totalTime: totalTime)
        }
    }
    
    private func calculateDailyProgress(from data: [StopwatchData]) -> [(date: Date, totalTime: TimeInterval)] {
        let (startDate, endDate) = getPeriodRange()
        var dailyTotals: [Date: TimeInterval] = [:]
        
        // Initialize all days in period with 0
        var currentDate = startDate
        while currentDate < endDate {
            let dayStart = calendar.startOfDay(for: currentDate)
            dailyTotals[dayStart] = 0
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? endDate
        }
        
        // Add actual data
        for stopwatchData in data {
            let dayStart = calendar.startOfDay(for: stopwatchData.completionDate)
            dailyTotals[dayStart, default: 0] += stopwatchData.totalInterval
        }
        
        return dailyTotals.sorted { $0.key < $1.key }.map { (date: $0.key, totalTime: $0.value) }
    }
    
    private func calculateWeeklyComparison() -> [(week: String, totalTime: TimeInterval)] {
        let endDate = calendar.startOfDay(for: selectedDate)
        var weeklyTotals: [(week: String, totalTime: TimeInterval)] = []
        
        // Get last 4 weeks for comparison
        for weekOffset in 0..<4 {
            let weekEndDate = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: endDate) ?? endDate
            let weekStartDate = calendar.date(byAdding: .day, value: -6, to: weekEndDate) ?? weekEndDate
            
            let weekData = stopwatchData.filter { data in
                data.completionDate >= weekStartDate && data.completionDate <= weekEndDate
            }
            
            let totalTime = weekData.reduce(0) { $0 + $1.totalInterval }
            let weekString = weekOffset == 0 ? "This Week" : "\(weekOffset + 1) weeks ago"
            
            weeklyTotals.append((week: weekString, totalTime: totalTime))
        }
        
        return weeklyTotals.reversed() // Show chronologically
    }
    
    // Helper methods for UI
    func getProgressPercentage() -> Double {
        guard totalTimeThisPeriod > 0 else { return 0 }
        
        // Define goals based on period (these could be user-configurable)
        let goalMinutes: Double = switch selectedPeriod {
        case .week: 180 // 3 hours per week
        case .month: 720 // 12 hours per month  
        case .threeMonths: 2160 // 36 hours per 3 months
        case .year: 8760 // 146 hours per year (about 30 min/day)
        }
        
        let goalSeconds = goalMinutes * 60
        return min(totalTimeThisPeriod / goalSeconds, 1.0)
    }
    
    func getCompletionStreak() -> Int {
        // Calculate current streak of days with completed exercises
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        while true {
            let hasDataForDay = stopwatchData.contains { data in
                calendar.isDate(data.completionDate, inSameDayAs: currentDate)
            }
            
            if hasDataForDay {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
}

// MARK: - Supporting Types

enum StatisticsPeriod: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month" 
    case threeMonths = "3 Months"
    case year = "Year"
    
    var id: String { rawValue }
}

// MARK: - DateFormatter Extensions

extension DateFormatter {
    static let dayOfWeek: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}
