//
//  MusicPlayerViewFactory.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 17.05.25.
//

import SwiftUI

struct MusicPlayerViewFactory {
    static func makeView() -> some View {
        let viewModel = MusicPlayerViewModel()
        return MusicPlayerView(viewModel: viewModel)
    }
}
