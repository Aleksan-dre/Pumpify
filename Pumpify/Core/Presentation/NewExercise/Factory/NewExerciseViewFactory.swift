//
//  NewExerciseViewFactory.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 07.07.25.
//

import SwiftUI

@MainActor
struct NewExerciseViewFactory {
    static func make(
        workout: Workout,
        repository: any DataRepositoryProtocol
    ) -> some View {
        let viewModel = NewExerciseViewModel(workout: workout, repository: repository)
        return NewExerciseView(viewModel: viewModel)
    }
}
