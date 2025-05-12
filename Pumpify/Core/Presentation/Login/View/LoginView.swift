//
//  LoginView.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 12.05.25.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    
    var body: some View {
        Button("Google Sign In") {
            viewModel.loginWithGoogle()
        }
    }
}
