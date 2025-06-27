//
//  SignUpViewFactory.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 22.05.25.
//

import SwiftUI

struct SignUpViewFactory {
    static func make() -> some View {
        let viewModel = SignUpViewModel()
        return SignUpView(viewModel: viewModel)
    }
}
