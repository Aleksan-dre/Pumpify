//
//  LoginViewModel.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 12.05.25.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

final class LoginViewModel: ObservableObject {
    func loginWithGoogle() {
        AuthService.shared.loginWithGoogle { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    print(user.email ?? "No email")
                    UserDefaults.standard.set(true, forKey: "isSignedIn")
                }
            case .failure(let error):
                print("Error signing in: \(error.localizedDescription)")
            }
        }
    }
}
