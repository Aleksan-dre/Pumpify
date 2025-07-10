//
//  StatisticsViewFactory.swift
//  Pumpify
//
//  Created by AI Assistant on $(date).
//

import SwiftUI

struct StatisticsViewFactory {
    @MainActor
    static func make(repository: any DataRepositoryProtocol) -> some View {
        let viewModel = StatisticsViewModel(repository: repository)
        return StatisticsView(viewModel: viewModel)
    }
}
