//
//  LoginViewFactory.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 17.05.25.
//

import SwiftUI

struct LoginViewFactory {
    static func make() -> some View {
        let viewModel = LoginViewModel()
        return LoginView(viewModel: viewModel)
    }
}
