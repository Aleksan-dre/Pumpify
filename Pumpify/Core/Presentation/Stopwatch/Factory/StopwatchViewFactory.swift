//
//  StopwatchFactory.swift
//  Pumpify
//
//  Created by TimurSmoev on 6/27/25.
//

import SwiftUI

struct StopwatchViewFactory {
    @MainActor
    static func make(
        exerciseId: UUID,
        date: Date,
        updating stopwatchDataToUpdate: StopwatchData? = nil,
        repository: any DataRepositoryProtocol
    ) -> some View {
        let viewModel = StopwatchViewModel(
            exerciseId: exerciseId,
            date: date,
            stopwatchDataToUpdate: stopwatchDataToUpdate,
            repository: repository
        )
        return Stopwatch(viewModel: viewModel)
    }
}
