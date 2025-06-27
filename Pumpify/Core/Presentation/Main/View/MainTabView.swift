//
//  MainTabView.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 11.05.25.
//

import SwiftUI

private enum AppTab {
    case music, exercise, stats, settings
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .exercise
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Music Player
            MusicPlayerViewFactory.make()
                .tabItem {
                    Label("Music", systemImage: "music.note.list")
                }
                .tag(AppTab.music)
            
            // MARK: – Exercises
            Text("Exercises")
            .tabItem {
                Label("Excersises", systemImage: "dumbbell")
            }
            .tag(AppTab.exercise)

            // MARK: – Statistics
            NavigationStack {
                Text("Statistics")
            }
            .tabItem {
                Label("Stats", systemImage: "chart.xyaxis.line")
            }
            .tag(AppTab.stats)
            
            // MARK: – Settings
            SettingsView()
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(AppTab.settings)
        }
    }
}
