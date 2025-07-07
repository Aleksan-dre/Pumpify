//
//  SettingsViewModel.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 07.07.25.
//

import Foundation
import SwiftData
import SwiftUI
import UserNotifications

@MainActor
final class SettingsViewModel: BaseViewModel {
    @Published var settings: Settings?
    @Published var notificationPermission = UNAuthorizationStatus.notDetermined
    @Published var notificationsEnabled = true
    @Published var darkModeEnabled = false
    @Published var username = "User"
    
    override init(repository: any DataRepositoryProtocol) {
        super.init(repository: repository)
        
        Task {
            await loadSettings()
            await checkNotificationPermission()
        }
    }
    
    @MainActor
    func loadSettings() async {
        await withErrorHandling {
            self.settings = try await self.repository.fetchSettings()
        }
    }
    
    @MainActor
    func saveSettings() async {
        guard let settings = settings else { return }
        
        await withErrorHandling {
            try await self.repository.updateSettings(settings)
        }
    }
    
    @MainActor
    func checkNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        notificationPermission = settings.authorizationStatus
    }
    
    @MainActor
    func requestNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await checkNotificationPermission()
        } catch {
            handleError(error)
        }
    }
    
    func updateFirstName(_ firstName: String) {
        settings?.firstName = firstName.isEmpty ? nil : firstName
        Task {
            await saveSettings()
        }
    }
    
    func updateLastName(_ lastName: String) {
        settings?.lastName = lastName.isEmpty ? nil : lastName
        Task {
            await saveSettings()
        }
    }
    
    func updateBirthday(_ birthday: Date) {
        settings?.birthday = birthday
        Task {
            await saveSettings()
        }
    }
    
    func updateAccentColor(_ accentColor: AccentColor) {
        settings?.accentColor = accentColor
        Task {
            await saveSettings()
        }
    }
    
    func updateDynamicFontSize(_ size: CGFloat) {
        settings?.dynamicFontSize = size
        Task {
            await saveSettings()
        }
    }
    
    func updateNotificationTime(_ time: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        settings?.notificationTime = HourAndMinute(
            hour: components.hour ?? 8,
            minute: components.minute ?? 0
        )
        Task {
            await saveSettings()
        }
    }
    
    func toggleNotifications(_ enabled: Bool) {
        notificationsEnabled = enabled
        // Handle notification scheduling/cancellation logic here
    }
    
    @MainActor
    func refreshData() async {
        await withErrorHandling {
            try await self.repository.forceRefreshData()
            await self.loadSettings()
            await self.checkNotificationPermission()
        }
    }
}
