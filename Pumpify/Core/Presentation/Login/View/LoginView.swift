//
//  LoginView.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 12.05.25.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    @State var isSignUpPresented = false
    
    var body: some View {
        NavigationStack {
            content
                .navigationDestination(isPresented: $isSignUpPresented) {
                    SignUpViewFactory.makeView()
                }
                .navigationDestination(isPresented: $viewModel.isLoggedIn) {
                    MainTabViewFactory.makeView(onSignOut: {})
                }
        }
    }
}

// MARK: - Content
private extension LoginView {
    var content: some View {
        VStack(spacing: .zero) {
            header
            Spacer(minLength: .zero)
            emailField
            passwordField
            submitButton
            Spacer(minLength: .zero)
            signUpWithEmailButton
            googleButton
        }
    }
}

// MARK: - Title
private extension LoginView {
    var header: some View {
        VStack(spacing: .assets.xs) {
            Text("Pumpify")
                .fontWeight(.bold)
                .font(.system(size: 56, weight: .heavy, design: .default))
                .foregroundColor(.primary)
            
            Text("Pump your body")
                .font(.system(size: 24, weight: .regular, design: .serif))
        }
        .padding(.top, .assets.xl5)
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
        .padding(.horizontal, .assets.lg)
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
        .padding(.horizontal, .assets.lg)
        .padding(.bottom, .assets.xl2)
    }
}

// MARK: - Buttons
private extension LoginView {
    var submitButton: some View {
        GeneralButton(
            title: Constants.buttonText,
            isEnabled: viewModel.isButtonActive,
            action: viewModel.logInWithEmailAndPassword
        )
        .padding(.bottom, .assets.xl)
        .padding(.horizontal, .assets.xl5)
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
    
    var signUpWithEmailButton: some View {
        SignInButton(
            title: "Register with Email",
            icon: Image("envelope-icon"),
            action: { isSignUpPresented = true }
        )
        .padding(.horizontal, .assets.sm)
        .padding(.bottom, .assets.sm)
    }
}

private extension LoginView {
    enum Constants {
        static let buttonText: String = "Continue"
    }
}
