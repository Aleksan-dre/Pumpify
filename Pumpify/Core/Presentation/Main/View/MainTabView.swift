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
    @Environment(\.modelContext) private var context
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
            HomeViewFactory.make()
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(AppTab.exercise)

            // MARK: – Statistics
            WorkoutsViewFactory.make(context: context)
            .tabItem {
                Label("Workouts", systemImage: "list.bullet.clipboard")
            }
            .tag(AppTab.stats)
            
            // MARK: – Settings
            SettingsView()
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(AppTab.settings)
        }
        .navigationBarBackButtonHidden(true)
    }
}
