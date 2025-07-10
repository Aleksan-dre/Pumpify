//
//  StatisticsViewFactory.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 11.07.2025.
//

import SwiftUI

struct StatisticsViewFactory {
    @MainActor
    static func make(repository: any DataRepositoryProtocol) -> some View {
        let viewModel = StatisticsViewModel(repository: repository)
        return StatisticsView(viewModel: viewModel)
    }
}
