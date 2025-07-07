//
//  SignUpViewModel.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 22.05.25.
//

import Combine
import Foundation
import FirebaseAuth

final class SignUpViewModel: ObservableObject {
    @Published var email: String = .empty
    @Published var password: String = .empty
    @Published var confirmPassword: String = .empty

    @Published var emailErrorMessage: String? = .empty
    @Published var passwordErrorMessage: String? = .empty
    @Published var confirmPasswordErrorMessage: String? = .empty

    @Published var isEmailValid = true
    @Published var isPasswordValid = true
    @Published var isConfirmPasswordValid = true

    @Published var isEmailCorrect = true
    @Published var isPasswordCorrect = true
    @Published var isButtonActive = false
    @Published var isLoggedIn = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
    }

    private func setupBindings() {
        $email
            .sink { [weak self] email in
                self?.validateEmail(email)
            }
            .store(in: &cancellables)

        Publishers.CombineLatest($password, $confirmPassword)
            .sink { [weak self] password, confirm in
                self?.validatePasswords(password, confirm)
            }
            .store(in: &cancellables)

        Publishers.CombineLatest3($isEmailValid, $isConfirmPasswordValid, $password)
            .map { isEmailValid, isConfirmPasswordValid, password in
                isEmailValid && isConfirmPasswordValid && !password.isEmpty
            }
            .assign(to: &$isButtonActive)
    }

    private func validateEmail(_ email: String) {
        guard !email.isEmpty else {
            isEmailValid = true
            return
        }
        let isValid = InputValidationService.isValid(email, for: .email)
        if !isValid {
            isEmailValid = false
            emailErrorMessage = "Email has incorrect format"
        } else {
            isEmailValid = true
        }
    }

    func validatePasswords(_ password: String, _ confirmPassword: String) {
        if password != confirmPassword {
            confirmPasswordErrorMessage = "Passwords do not match"
            isConfirmPasswordValid = false
        } else {
            confirmPasswordErrorMessage = nil
            isConfirmPasswordValid = true
        }
    }

    func loginWithGoogle() {
        AuthService.shared.loginWithGoogle { result in
            switch result {
            case .success:
                // AuthState will be updated automatically via Firebase auth listener
                print("✅ Google login successful")
            case .failure(let error):
                print("❌ Error signing in with Google: \(error.localizedDescription)")
            }
        }
    }

    func register() {
        AuthService.shared.signUpWithEmail(email: email, password: password) { result in
            switch result {
            case .success:
                // AuthState will be updated automatically via Firebase auth listener
                print("✅ Email/password registration successful")
            case .failure(let error):
                print("❌ Error signing up: \(error.localizedDescription)")
            }
        }
    }
}
