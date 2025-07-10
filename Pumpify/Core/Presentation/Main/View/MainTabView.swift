//
//  MainTabView.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 11.05.25.
//

import SwiftUI
import SwiftData

private enum AppTab {
    case music, exercise, stats, calendar, home, workouts
}

struct MainTabView: View {
    @Environment(\.modelContext) private var context
    @State private var selectedTab: AppTab = .home
    @StateObject private var repository: DataRepository
    @State private var hasInitialized = false
    
    @Query var settingsList: [Settings]
    var settings: Settings? { settingsList.first }
    
    init(context: ModelContext) {
        self._repository = StateObject(wrappedValue: DataRepository(modelContext: context))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Music Player
            MusicPlayerViewFactory.make()
                .tabItem {
                    Label("Music", systemImage: "music.note.list")
                }
                .tag(AppTab.music)

            // MARK: – Calendar
            CalendarViewFactory.make(repository: repository)
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
            .tag(AppTab.calendar)

            // MARK: – Home Page
            HomeViewFactory.make(repository: repository)
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(AppTab.home)
            
            // MARK: – Workouts
            WorkoutsViewFactory.make(repository: repository)
            .tabItem {
                Label("Workouts", systemImage: "list.bullet.clipboard")
            }
            .tag(AppTab.workouts)
            
            // MARK: – Statistics
            StatisticsViewFactory.make(repository: repository)
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }
            .tag(AppTab.stats)
        }
        .accentColor(settings?.accentColor.swiftuiAccentColor ?? .yellow)
        .navigationBarBackButtonHidden(true)
        .task {
            if !hasInitialized {
                await handleInitialLogin()
                hasInitialized = true
            }
        }
    }
    
    @MainActor
    private func handleInitialLogin() async {
        do {
            try await repository.handleInitialLogin()
        } catch {
            print("❌ Failed to handle initial login: \(error)")
        }
    }
}
