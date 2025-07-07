//
//  HomeViewFactory.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 27.06.25.
//

import SwiftUI
import SwiftData

@MainActor
struct HomeViewFactory {
    static func make(repository: any DataRepositoryProtocol) -> some View {
        let viewModel = HomeViewModel(repository: repository)
        return HomeView(viewModel: viewModel)
    }
}
