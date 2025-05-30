//
//  LoginViewModel.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 12.05.25.
//

import SwiftUI
import Combine
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

final class LoginViewModel: ObservableObject {
    @Published var email: String = .empty
    @Published var password: String = .empty
    @Published var emailErrorMessage: String? = .empty
    @Published var passwordErrorMessage: String? = .empty
    @Published var isEmailValid = true
    @Published var isPasswordValid = true
    @Published var isEmailCorrect = true
    @Published var isPasswordCorrect = true
    @Published var isButtonActive = false
    @Published var isLoggedIn = false
    @Published var showAlert = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        setupBindings()
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
            return
        }
        isEmailValid = true
    }
    
    private func setupBindings() {
        $email
            .sink { [weak self] email in
                self?.validateEmail(email)
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest3($isEmailValid, $email, $password)
            .map { isEmailValid, email, password in
                isEmailValid && !email.isEmpty && !password.isEmpty
            }
            .assign(to: &$isButtonActive)
        print(isButtonActive)
    }
    
    func loginWithGoogle() {
        AuthService.shared.loginWithGoogle { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                }
            case .failure(let error):
                print("Error signing in: \(error.localizedDescription)")
            }
        }
    }
    
    func logInWithEmailAndPassword() {
        AuthService.shared.logInWithEmailAndPassword(
            email: email,
            password: password
        ) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                }
            case .failure(let error):
                print("Error signing in: \(error.localizedDescription)")
            }
        }
    }
}
