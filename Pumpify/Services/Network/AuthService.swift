//
//  AuthService.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 12.05.25.
//

import FirebaseAuth
import GoogleSignIn
import FirebaseCore

final class AuthService {
    static let shared = AuthService()
    private var idToken: String?
    private var accessToken: String?
    private var currentUser: User?
    
    func loginWithGoogle(completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(NSError(domain: "No Client ID", code: 0, userInfo: nil)))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: UIViewController.getRootViewController()) { [weak self] result, error in
            guard let self = self, error == nil, let user = result?.user else {
                completion(.failure(error ?? NSError(domain: "Unknown Error", code: 0, userInfo: nil)))
                return
            }
            
            guard let idToken = user.idToken?.tokenString else {
                completion(.failure(NSError(domain: "Token Error", code: 0, userInfo: nil)))
                return
            }
            
            self.idToken = idToken
            self.accessToken = user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken ?? .empty
            )
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                self.currentUser = authResult?.user
                completion(.success(authResult!.user))
            }
        }
    }
    
    func signUpWithEmail(
        email: String,
        password: String,
        completion: @escaping (
            Result<User, Error>
        ) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user else {
                completion(.failure(NSError(domain: "No user returned", code: 0, userInfo: nil)))
                return
            }

            self?.currentUser = user
            user.getIDToken { token, error in
                self?.idToken = token
            }

            completion(.success(user))
        }
    }
    
    func logInWithEmailAndPassword(
        email: String,
        password: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "No user returned", code: 0, userInfo: nil)))
                return
            }

            self?.currentUser = user
            user.getIDToken { token, error in
                self?.idToken = token
            }

            completion(.success(user))
        }
    }
    
    func getCurrentUser() -> User? {
        return currentUser
    }
    
    func getIDToken() -> String? {
        return idToken
    }

    func getAccessToken() -> String? {
        return accessToken
    }
    
    func refreshUser() {
        guard FirebaseApp.app() != nil else { return }
        currentUser = Auth.auth().currentUser
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        idToken = nil
        accessToken = nil
        currentUser = nil
    }
}
