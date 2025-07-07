//
//  StopwatchViewModel.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 07.07.25.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
final class StopwatchViewModel: BaseViewModel {
    @Published var timeElapsed: String = "00:00:00"
    @Published var isRunning: Bool = false
    @Published var hasStarted: Bool = false
    @Published var previousElapsedTime: TimeInterval = 0
    @Published var currentElapsedTime: TimeInterval = 0
    @Published var period: TimeInterval = 60
    @Published var stopwatchData: [(Date, Date)]
    
    @Published var manualStartDate: Date
    @Published var manualEndDate: Date
    
    private let exerciseId: UUID
    private let date: Date
    private let stopwatchDataToUpdate: StopwatchData?
    private var timer: Timer?
    private var startTime: Date?

    var elapsedPeriods: Double { totalElapsedTime / period }
    var totalElapsedTime: TimeInterval { previousElapsedTime + currentElapsedTime }

    init(
        exerciseId: UUID,
        date: Date,
        stopwatchDataToUpdate: StopwatchData? = nil,
        repository: any DataRepositoryProtocol
    ) {
        self.exerciseId = exerciseId
        self.date = date
        self.stopwatchDataToUpdate = stopwatchDataToUpdate
        self.manualStartDate = date
        self.manualEndDate = date
        
        // Initialize empty arrays before calling super.init
        self.stopwatchData = []
        
        super.init(repository: repository)
        
        // Now safely initialize after super.init
        if let existing = stopwatchDataToUpdate {
            let times = existing.times.map { ($0.start, $0.end) }
            self.stopwatchData = times
            self.previousElapsedTime = times.reduce(0) { $0 + $1.0.distance(to: $1.1) }
        } else {
            self.previousElapsedTime = 0
        }
        
        updateTimeElapsed(previousElapsedTime)
    }

    func start() {
        isRunning = true
        hasStarted = true
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, let startTime = self.startTime else { return }
                let sinceStart = Date().timeIntervalSince(startTime)
                self.currentElapsedTime = sinceStart
                self.updateTimeElapsed(self.totalElapsedTime)
            }
        }
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        if let startTime = startTime {
            let endTime = Date()
            stopwatchData.append((startTime, endTime))
            previousElapsedTime = totalElapsedTime
            currentElapsedTime = 0
            self.startTime = nil
        }
    }

    @MainActor
    func save() async -> Bool {
        stop()
        
        return await withErrorHandling {
            let times = self.stopwatchData.map { Time(start: $0.0, end: $0.1) }
            let newData = StopwatchData(
                completionDate: self.date,
                exerciseId: self.exerciseId,
                times: times
            )
            
            if let existingData = self.stopwatchDataToUpdate {
                // Update existing data
                existingData.times = times
                try await self.repository.updateStopwatchData(existingData)
            } else {
                // Save new data
                try await self.repository.saveStopwatchData(newData)
            }
            return true
        } ?? false
    }

    @MainActor
    func saveManual() async -> Bool {
        let startDate = manualStartDate.withoutSeconds()
        let endDate = manualEndDate.withoutSeconds()
        
        guard startDate != endDate else { return false }
        
        return await withErrorHandling {
            let newData = StopwatchData(
                completionDate: self.date,
                exerciseId: self.exerciseId,
                times: [Time(start: startDate, end: endDate)]
            )
            try await self.repository.saveStopwatchData(newData)
            return true
        } ?? false
    }

    private func updateTimeElapsed(_ elapsed: TimeInterval) {
        let seconds = Int(elapsed) % 60
        let minutes = Int(elapsed / 60) % 60
        let hours = Int(elapsed / 3600)
        timeElapsed = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    var allowsManualEntry: Bool {
        stopwatchDataToUpdate == nil
    }
    
    deinit {
        timer?.invalidate()
    }
}
