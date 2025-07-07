//
//  NewWorkoutViewFactory.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 07.07.25.
//

import SwiftUI

@MainActor
struct NewWorkoutViewFactory {
    static func make(repository: any DataRepositoryProtocol) -> some View {
        let viewModel = NewWorkoutViewModel(repository: repository)
        return NewWorkoutView(viewModel: viewModel)
    }
}
