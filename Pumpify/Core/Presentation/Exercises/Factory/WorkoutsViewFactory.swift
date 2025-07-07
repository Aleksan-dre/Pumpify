//
//  WorkoutsViewFactory.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 28.06.25.
//

import SwiftUI
import SwiftData

@MainActor
struct WorkoutsViewFactory {
    static func make(repository: any DataRepositoryProtocol) -> some View {
        let viewModel = WorkoutsViewModel(repository: repository)
        return WorkoutsView(viewModel: viewModel)
    }
}
