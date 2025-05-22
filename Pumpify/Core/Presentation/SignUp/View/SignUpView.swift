//
//  SignUpView.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 22.05.25.
//

import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel: SignUpViewModel
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Create Account")
                .navigationDestination(isPresented: $viewModel.isLoggedIn) {
                    MainTabViewFactory.makeView(onSignOut: {})
                }
        }
    }
}

private extension SignUpView {
    var content: some View {
        VStack(spacing: .zero) {
            header
            Spacer(minLength: .zero)
            emailField
            passwordField
            confirmPasswordField
            registerButton
            Spacer(minLength: .zero)
            googleButton
        }
        .padding()
    }
    
    var header: some View {
        VStack(spacing: .assets.xs) {
            Text("Create Account")
                .font(.system(size: 32, weight: .bold))
            Text("Join Pumpify and start your journey")
                .font(.subheadline)
        }
        .padding(.top, .assets.xl5)
    }
    
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
        .padding(.bottom, .assets.xs3)
    }
    
    var confirmPasswordField: some View {
        InputField(
            text: $viewModel.confirmPassword,
            type: .password,
            placeholder: "Confirm Password",
            isInputValid: $viewModel.isConfirmPasswordValid,
            isInputCorrect: .constant(true),
            errorMessage: $viewModel.confirmPasswordErrorMessage,
            isEnabled: true
        )
        .padding(.bottom, .assets.xl2)
    }
    
    var googleButton: some View {
        SignInButton(
            title: "Continue with Google",
            icon: Image("google-icon"),
            action: viewModel.loginWithGoogle
        )
        .padding(.horizontal, .assets.sm)
        .padding(.bottom, .assets.xl3)
    }

    var registerButton: some View {
        GeneralButton(
            title: "Register",
            isEnabled: viewModel.isButtonActive,
            action: viewModel.register
        )
        .padding(.horizontal, .assets.xl5)
    }
}
