//
//  StopwatchFactory.swift
//  Pumpify
//
//  Created by TimurSmoev on 6/27/25.
//

import SwiftUI

struct StopwatchViewFactory {
    static func make(
        exerciseId: UUID,
        date: Date,
        updating stopwatchDataToUpdate: StopwatchData? = nil
    ) -> some View {
        let viewModel = StopwatchViewModel(
            exerciseId: exerciseId,
            date: date,
            stopwatchDataToUpdate: stopwatchDataToUpdate
        )
        return Stopwatch(viewModel: viewModel)
    }
}
