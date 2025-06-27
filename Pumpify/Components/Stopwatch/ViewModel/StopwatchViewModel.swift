//
//  StopwatchViewModel.swift
//  Pumpify
//
//  Created by TimurSmoev on 6/27/25.
//

import Foundation
import SwiftData
import SwiftUI

class StopwatchViewModel: ObservableObject {
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
        stopwatchDataToUpdate: StopwatchData? = nil
    ) {
        self.exerciseId = exerciseId
        self.date = date
        self.stopwatchDataToUpdate = stopwatchDataToUpdate
        self.manualStartDate = date
        self.manualEndDate = date
        
        if let existing = stopwatchDataToUpdate {
            self.stopwatchData = existing.times.map { ($0.start, $0.end) }
            self.previousElapsedTime = stopwatchData.reduce(0) { $0 + $1.0.distance(to: $1.1) }
        } else {
            self.stopwatchData = []
        }
        updateTimeElapsed(previousElapsedTime)
    }

    func start() {
        isRunning = true
        hasStarted = true
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self, let startTime else { return }
            let sinceStart = Date().timeIntervalSince(startTime)
            currentElapsedTime = sinceStart
            updateTimeElapsed(totalElapsedTime)
        }
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
        if let startTime = startTime {
            let endTime = Date()
            previousElapsedTime += endTime.timeIntervalSince(startTime)
            stopwatchData.append((startTime, endTime))
            self.startTime = nil
            currentElapsedTime = 0
            updateTimeElapsed(previousElapsedTime)
        }
    }

    func reset() {
        stop()
        hasStarted = false
        previousElapsedTime = 0
        stopwatchData.removeAll()
        updateTimeElapsed(0)
    }

    func save(context: ModelContext, dismiss: DismissAction) {
        stop()
        if let existing = stopwatchDataToUpdate {
            existing.times = stopwatchData.map { Time(start: $0.0, end: $0.1) }
        } else {
            let newData = StopwatchData(
                completionDate: date,
                exerciseId: exerciseId,
                times: stopwatchData.map { Time(start: $0.0, end: $0.1) }
            )
            context.insert(newData)
        }
        dismiss()
    }

    func saveManual(context: ModelContext, dismiss: DismissAction) {
        let startDate = manualStartDate.withoutSeconds()
        let endDate = manualEndDate.withoutSeconds()
        let newData = StopwatchData(
            completionDate: date,
            exerciseId: exerciseId,
            times: [
                Time(start: startDate, end: endDate)
            ]
        )
        context.insert(newData)
        dismiss()
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
}
