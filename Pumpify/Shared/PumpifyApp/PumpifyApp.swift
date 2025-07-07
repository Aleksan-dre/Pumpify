//
//  PumpifyApp.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 11.05.25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import AVFoundation
import SwiftData
import FirebaseAuth

final class AuthState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUserId: String?
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                let wasLoggedIn = self?.isLoggedIn ?? false
                let previousUserId = self?.currentUserId
                
                self?.isLoggedIn = user != nil
                self?.currentUserId = user?.uid
                
                // If user switched (logged out then back in as different user), 
                // we need to clear local data
                if wasLoggedIn && user != nil && previousUserId != user?.uid {
                    self?.handleUserSwitch()
                }
            }
        }
    }
    
    private func handleUserSwitch() {
        // Notify that user has switched - this will trigger data clearing
        NotificationCenter.default.post(name: .userDidSwitch, object: nil)
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

extension Notification.Name {
    static let userDidSwitch = Notification.Name("userDidSwitch")
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        AuthService.shared.refreshUser()
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct PumpifyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authState = AuthState()
    
    let container = ModelContainer.initializeModelContainer()
    
    var body: some Scene {
        WindowGroup {
            if authState.isLoggedIn {
                MainTabViewFactory.make(context: container.mainContext)
                    .environmentObject(authState)
            } else {
                LoginViewFactory.make()
                    .environmentObject(authState)
            }
        }
        .modelContainer(container)
    }
}
