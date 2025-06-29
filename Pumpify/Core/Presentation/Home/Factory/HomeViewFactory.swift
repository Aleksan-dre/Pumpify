//
//  HomeViewFactory.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 27.06.25.
//

import SwiftUI

@MainActor
struct HomeViewFactory {
    static func make() -> some View {
        let viewModel = HomeViewModel()
        return HomeView(viewModel: viewModel)
    }
}
