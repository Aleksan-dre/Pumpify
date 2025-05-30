//
//  SettingsView.swift
//  Pumpify
//
//  Created by Timur Smoev on 12.05.25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authState: AuthState
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var username = "User"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile")) {
                    TextField("Name", text: $username)
                    
                    Button("Edit Profile") {
                        // Action to edit profile
                    }
                }
                
                Section(header: Text("Preferences")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                }
                
                Section(header: Text("App")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    Button("Privacy Policy") {
                        // Action to show privacy policy
                    }
                    
                    Button("Terms of Service") {
                        // Action to show terms of service
                    }
                }
                
                Section {
                    Button("Log Out") {
                        
                        do {
                            try AuthService.shared.signOut()
                            authState.isLoggedIn = false
                        } catch {
                            print("Sign out failed: \(error.localizedDescription)")
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
