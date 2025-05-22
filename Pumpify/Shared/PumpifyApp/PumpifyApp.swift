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
    @State private var isLoggedIn = AuthService.shared.getCurrentUser() != nil

    var body: some Scene {
        WindowGroup {
            if !isLoggedIn {
                LoginViewFactory
                    .makeView()
                    .tint(.orange)
            } else {
                MainTabViewFactory
                    .makeView(onSignOut: { isLoggedIn = false })
                    .tint(.orange)
            }
        }
    }
}
