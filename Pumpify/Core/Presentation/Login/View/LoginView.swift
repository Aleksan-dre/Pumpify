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
        content
    }
}

// MARK: - Content
private extension LoginView {
    var content: some View {
        VStack(spacing: .zero) {
            Spacer(minLength: .zero)
            emailField
            passwordField
            submitButton
            Spacer(minLength: .zero)
            googleButton
        }
    }
}

// MARK: - Title
private extension LoginView {
    var title: some View {
        Text("Login")
            .font(.title)
            .foregroundColor(.primary)
    }
}

// MARK: - Input
private extension LoginView {
    var emailField: some View {
        InputField(
            text: $viewModel.email,
            type: .email,
            placeholder: "Email",
            isInputValid: $viewModel.isEmailValid,
            isInputCorrect: $viewModel.isEmailCorrect,
            errorMessage: $viewModel.emailErrorMessage,
            isEnabled: true
        )
        .padding(.horizontal, .assets.xs)
        .padding(.bottom, .assets.xs3)
    }
    
    var passwordField: some View {
        InputField(
            text: $viewModel.password,
            type: .password,
            placeholder: "Password",
            isInputValid: $viewModel.isPasswordValid,
            isInputCorrect: $viewModel.isPasswordCorrect,
            errorMessage: $viewModel.passwordErrorMessage,
            isEnabled: true
        )
        .padding(.horizontal, .assets.xs)
        .padding(.bottom, .assets.xl2)
    }
}

// MARK: - Buttons
private extension LoginView {
    var submitButton: some View {
        GeneralButton(
            title: Constants.buttonText,
            isEnabled: viewModel.isButtonActive,
            action: { }
        )
        .padding(.bottom, .assets.xl)
        .padding(.horizontal, .assets.xl5)
    }
    
    var googleButton: some View {
        GoogleSignInButton(action: viewModel.loginWithGoogle)
            .padding(.horizontal, .assets.sm)
            .padding(.bottom, .assets.xl3)
    }
}

private extension LoginView {
    enum Constants {
        static let buttonText: String = "Continue"
    }
}
