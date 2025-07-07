//
//  ExerciseDetailsViewFactory.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 07.07.25.
//

import SwiftUI
import SwiftData

@MainActor
struct ExerciseDetailsViewFactory {
    static func make(date: Date, repository: any DataRepositoryProtocol) -> some View {
        let viewModel = ExerciseDetailsViewModel(date: date, repository: repository)
        return ExerciseDetailsView(date: date, viewModel: viewModel)
    }
}
