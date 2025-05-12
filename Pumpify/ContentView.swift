//
//  ContentView.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 11.05.25.
//

// ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(1)
            
            MusicPlayerView()
                .tabItem {
                    Label("Music", systemImage: "music.note")
                }
                .tag(2)
            
            ProjectView()
                .tabItem {
                    Label("Project", systemImage: "list.bullet.clipboard")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}
