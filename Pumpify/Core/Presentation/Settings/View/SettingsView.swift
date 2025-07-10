//
//  SettingsView.swift
//  Pumpify
//
//  Created by Timur Smoev on 12.05.25.
//

import SwiftUI
import SwiftData

let dailyNotificationId = "DAILY_NOTIFICATION"
let notificationTitle = "Let's Check What You've Got For Today!"
let notificationSubtitle = "Motivation is what gets you started. Habit is what keeps you going."
let defaultHour = 8
let defaultMinute = 0

struct SettingsView: View {
    @EnvironmentObject var authState: AuthState
    @Environment(\.modelContext) var modelContext
    
    @State var notificationPermission = UNAuthorizationStatus.notDetermined
    @State var notificationsEnabled = true
    @State var darkModeEnabled = false
    @State var username = "User"
    
    @Query var settingsList: [Settings]
    var settings: Settings? { settingsList.first }
    
    var body: some View {
        NavigationStack {
            Form {
                personalInfoSection()
                visualSettingsSection()
                notificationSection()
                logoutSection()
            }
            .navigationTitle(Text("Settings"))
            .onAppear {
                markSettingsAsAccessed()
            }
        }
    }
}

private extension SettingsView {
    func notificationSection() -> some View {
        Section(header: Text("Notifications")) {
            switch notificationPermission {
            case .authorized, .provisional, .ephemeral:
                dailyReminderToggle()
                notificationTimePicker()
            case .denied:
                notificationPermissionDeniedView()
            case .notDetermined:
                enableRemindersButton()
            @unknown default:
                Text("Notification Permission Unknown")
            }
        }
        .font(.system(size: settings?.dynamicFontSize ?? 17))
    }

    
    func logoutSection() -> some View {
        Section(header: Text("Exit")) {
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
}

private extension SettingsView {
    /// Personal Information Section
    func personalInfoSection() -> some View {
        Section(header: Text("Personal Information")) {
            // Use the dynamic font size for TextFields and Labels
            TextField("First Name", text: textFieldBinding(for: \.firstName))
            TextField("Last Name", text: textFieldBinding(for: \.lastName))
                .autocorrectionDisabled(true)
            DatePicker("Birthday", selection: datePickerBinding(for: \.birthday), displayedComponents: .date)
        }
        .font(.system(size: settings?.dynamicFontSize ?? 17))
    }
    
    func textFieldBinding(for keyPath: WritableKeyPath<Settings, String?>) -> Binding<String> {
        Binding(
            get: { self.settings?[keyPath: keyPath] ?? "" },
            set: { newValue in
                var currentSettings = self.settings ?? self.createNewSettings()
                let finalValue = newValue.isEmpty ? nil : newValue
                currentSettings[keyPath: keyPath] = finalValue
                try? self.modelContext.save()
            }
        )
    }

    /// Visual Settings Section
    func visualSettingsSection() -> some View {
        Section(header: Text("Visual Settings")) {
            Picker("Accent Color", selection: pickerBinding(for: \.accentColor, defaultValue: AccentColor.yellow)) {
                Text("Yellow").tag(AccentColor.yellow)
                Text("Blue").tag(AccentColor.blue)
                Text("Purple").tag(AccentColor.purple)
                Text("Green").tag(AccentColor.green)
            }
            .font(.system(size: settings?.dynamicFontSize ?? 17))
        }
    }
    
    func pickerBinding<T>(for keyPath: WritableKeyPath<Settings, T>, defaultValue: T) -> Binding<T> {
        Binding(
            get: { self.settings?[keyPath: keyPath] ?? defaultValue },
            set: { newValue in
                var currentSettings = self.settings ?? self.createNewSettings()
                currentSettings[keyPath: keyPath] = newValue
                try? self.modelContext.save()
            }
        )
    }
    
    /// Extracting smaller view components
    func dailyReminderToggle() -> some View {
        Toggle(isOn: toggleBinding(), label: { Text("Daily Reminder")})
            .font(.system(size: settings?.dynamicFontSize ?? 17))
    }

    func notificationTimePicker() -> some View {
        Group {  /// Using Group instead of AnyView for better performance and simplicity
            if let notificationTime = settings?.notificationTime {
                DatePicker(
                    selection: datePickerBinding(forNotificationTime: notificationTime),
                    displayedComponents: .hourAndMinute
                ) {
                    Text("Notification Time")
                }
            } else {
                EmptyView()
            }
        }
    }

    func notificationPermissionDeniedView() -> some View {
        Group {
            Text("Notification Permission Denied")
            Button("Enable in Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }

    func enableRemindersButton() -> some View {
        Button("Enable Reminders") {
            requestNotificationPermission()
        }
        .onAppear {
            checkAndHandleNotificationPermission()
        }
    }
    
    func datePickerBinding(for keyPath: WritableKeyPath<Settings, Date?>) -> Binding<Date> {
        Binding(
            get: { self.settings?[keyPath: keyPath] ?? Date() }, // Default to current date if nil
            set: { newValue in
                var currentSettings = self.settings ?? self.createNewSettings()
                currentSettings[keyPath: keyPath] = newValue
                try? self.modelContext.save()
            }
        )
    }
    
    func toggleBinding() -> Binding<Bool> {
        Binding(
            get: { self.settings?.notificationTime != nil },
            set: { newValue in
                if newValue {
                    scheduleDailyNotification(for: DateComponents(calendar: Calendar.current, hour: defaultHour, minute: defaultMinute))
                } else {
                    removeDailyNotification()
                }
            }
        )
    }

    func datePickerBinding(forNotificationTime notificationTime: HourAndMinute) -> Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: notificationTime.hour, minute: notificationTime.minute, second: 0, of: Date()) ?? Date()
            },
            set: { newValue in
                let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                scheduleDailyNotification(for: dateComponents)
            }
        )
    }

    /// Functions for notification permission handling
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, _ in
            if success {
                scheduleDailyNotification(for: DateComponents(calendar: Calendar.current, hour: defaultHour, minute: defaultMinute))
            }
            refreshNotificationPermissionStatus()
        }
    }

    func checkAndHandleNotificationPermission() {
        refreshNotificationPermissionStatus()
        if notificationPermission == .notDetermined || notificationPermission == .denied {
            updateSettings { $0.notificationTime = nil }
        }
    }

    func refreshNotificationPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            notificationPermission = settings.authorizationStatus
        }
    }
    
    func removeDailyNotification(updatingDatabase: Bool = true) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [dailyNotificationId])
        if updatingDatabase {
            updateSettings { $0.notificationTime = nil }
        }
    }

    /// Function to schedule daily notifications.
    func scheduleDailyNotification(for dateComponents: DateComponents) {
        removeDailyNotification(updatingDatabase: false)
        let content = createNotificationContent()
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: dailyNotificationId,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
        updateSettings { $0.notificationTime = HourAndMinute(hour: dateComponents.hour ?? defaultHour, minute: dateComponents.minute ?? defaultMinute) }
    }

    /// Creating notification content to reduce complexity in scheduleDailyNotification
    func createNotificationContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.subtitle = notificationSubtitle
        content.sound = UNNotificationSound.default
        return content
    }
    
    func updateSettings(_ updateBlock: (_ settings: Settings) -> Void) {
        let currentSettings = settings ?? createNewSettings()
        updateBlock(currentSettings)
        try? modelContext.save()
    }
    
    func createNewSettings() -> Settings {
        let newSettings = Settings()
        modelContext.insert(newSettings)
        return newSettings
    }
    
    func markSettingsAsAccessed() {
        guard let currentSettings = settings else { return }
        if !currentSettings.hasAccessedSettings {
            currentSettings.hasAccessedSettings = true
            try? modelContext.save()
        }
    }
}

#Preview {
    SettingsView()
}
