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
            MusicPlayerViewFactory.makeView()
                .tabItem {
                    Label("Music", systemImage: "music.note.list")
                }
                .tag(AppTab.music)
            
            // MARK: – Exercises
            NavigationStack {
                // Suppose HomeViewFactory makes HomeViewController/ViewModel
                Text("Excersises")
            }
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
            
            // MARK: – Settings Tab
            NavigationStack {
                Text("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(AppTab.settings)
        }
    }
}
