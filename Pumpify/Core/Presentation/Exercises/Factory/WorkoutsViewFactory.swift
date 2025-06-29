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
    static func make(context: ModelContext) -> some View {
        let viewModel = WorkoutsViewModel(context: context)
        return WorkoutsView(viewModel: viewModel)
    }
}
