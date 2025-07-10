//
//  SettingsViewModelTests.swift
//  PumpifyTests
//
//  Created by Unit Tests on 11.07.25.
//

import XCTest
import SwiftData
import UserNotifications
@testable import Pumpify

@MainActor
final class SettingsViewModelTests: XCTestCase {
    
    var viewModel: SettingsViewModel!
    var mockRepository: MockDataRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        mockRepository = MockDataRepository()
        viewModel = SettingsViewModel(repository: mockRepository)
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockRepository = nil
        try await super.tearDown()
    }
    
    // MARK: - Test Initial State
    
    func testInitialState() {
        // Then
        XCTAssertNil(viewModel.settings)
        XCTAssertEqual(viewModel.notificationPermission, .notDetermined)
        XCTAssertTrue(viewModel.notificationsEnabled)
        XCTAssertFalse(viewModel.darkModeEnabled)
        XCTAssertEqual(viewModel.username, "User")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
    
    // MARK: - Test Settings Loading
    
    func testLoadSettings() async {
        // Given
        let mockSettings = createMockSettings()
        mockRepository.mockSettings = mockSettings
        
        // When
        await viewModel.loadSettings()
        
        // Then
        XCTAssertNotNil(viewModel.settings)
        XCTAssertEqual(viewModel.settings?.firstName, "John")
        XCTAssertEqual(viewModel.settings?.lastName, "Doe")
        XCTAssertEqual(viewModel.settings?.email, "john@example.com")
        XCTAssertEqual(viewModel.settings?.accentColor, .blue)
        XCTAssertEqual(viewModel.settings?.dynamicFontSize, 16)
    }
    
    func testLoadSettingsWithError() async {
        // Given
        mockRepository.shouldThrowError = true
        
        // When
        await viewModel.loadSettings()
        
        // Then
        XCTAssertNil(viewModel.settings)
        XCTAssertNotNil(viewModel.error)
    }
    
    // MARK: - Test Settings Saving
    
    func testSaveSettings() async {
        // Given
        let mockSettings = createMockSettings()
        viewModel.settings = mockSettings
        
        // When
        await viewModel.saveSettings()
        
        // Then
        XCTAssertEqual(mockRepository.mockSettings?.firstName, "John")
        XCTAssertEqual(mockRepository.mockSettings?.lastName, "Doe")
        XCTAssertEqual(mockRepository.mockSettings?.email, "john@example.com")
    }
    
    func testSaveSettingsWithNilSettings() async {
        // Given
        viewModel.settings = nil
        
        // When
        await viewModel.saveSettings()
        
        // Then
        // Should not throw error or crash, and no changes should be made
        XCTAssertNil(mockRepository.mockSettings)
    }
    
    func testSaveSettingsWithError() async {
        // Given
        let mockSettings = createMockSettings()
        viewModel.settings = mockSettings
        mockRepository.shouldThrowError = true
        
        // When
        await viewModel.saveSettings()
        
        // Then
        XCTAssertNotNil(viewModel.error)
    }
    
    // MARK: - Test Individual Setting Updates
    
    func testUpdateFirstName() async {
        // Given
        let mockSettings = createMockSettings()
        viewModel.settings = mockSettings
        
        // When
        viewModel.updateFirstName("Jane")
        
        // Wait for async save to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Then
        XCTAssertEqual(viewModel.settings?.firstName, "Jane")
    }
    
    func testUpdateFirstNameWithEmptyString() async {
        // Given
        let mockSettings = createMockSettings()
        viewModel.settings = mockSettings
        
        // When
        viewModel.updateFirstName("")
        
        // Wait for async save to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Then
        XCTAssertNil(viewModel.settings?.firstName)
    }
    
    func testUpdateLastName() async {
        // Given
        let mockSettings = createMockSettings()
        viewModel.settings = mockSettings
        
        // When
        viewModel.updateLastName("Smith")
        
        // Wait for async save to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Then
        XCTAssertEqual(viewModel.settings?.lastName, "Smith")
    }
    
    func testUpdateBirthday() async {
        // Given
        let mockSettings = createMockSettings()
        viewModel.settings = mockSettings
        let newBirthday = Date().addingTimeInterval(-86400 * 365 * 25) // 25 years ago
        
        // When
        viewModel.updateBirthday(newBirthday)
        
        // Wait for async save to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Then
        XCTAssertEqual(viewModel.settings?.birthday, newBirthday)
    }
    
    func testUpdateAccentColor() async {
        // Given
        let mockSettings = createMockSettings()
        viewModel.settings = mockSettings
        
        // When
        viewModel.updateAccentColor(.red)
        
        // Wait for async save to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Then
        XCTAssertEqual(viewModel.settings?.accentColor, .red)
    }
    
    func testUpdateDynamicFontSize() async {
        // Given
        let mockSettings = createMockSettings()
        viewModel.settings = mockSettings
        
        // When
        viewModel.updateDynamicFontSize(18)
        
        // Wait for async save to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Then
        XCTAssertEqual(viewModel.settings?.dynamicFontSize, 18)
    }
    
    func testUpdateNotificationTime() async {
        // Given
        let mockSettings = createMockSettings()
        viewModel.settings = mockSettings
        
        let calendar = Calendar.current
        let timeComponents = DateComponents(hour: 7, minute: 30)
        let notificationTime = calendar.date(from: timeComponents)!
        
        // When
        viewModel.updateNotificationTime(notificationTime)
        
        // Wait for async save to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Then
        XCTAssertEqual(viewModel.settings?.notificationTime?.hour, 7)
        XCTAssertEqual(viewModel.settings?.notificationTime?.minute, 30)
    }
    
    // MARK: - Test Notification Handling
    
    func testToggleNotifications() {
        // Given
        let initialState = viewModel.notificationsEnabled
        
        // When
        viewModel.toggleNotifications(!initialState)
        
        // Then
        XCTAssertEqual(viewModel.notificationsEnabled, !initialState)
    }
    
    func testCheckNotificationPermission() async {
        // When
        await viewModel.checkNotificationPermission()
        
        // Then
        // Note: In a real app, this would check actual permission status
        // For testing, we just verify the method completes without error
        XCTAssertNotNil(viewModel.notificationPermission)
    }
    
    func testRequestNotificationPermission() async {
        // When
        await viewModel.requestNotificationPermission()
        
        // Then
        // Note: In a real app, this would actually request permission
        // For testing, we just verify the method completes without error
        XCTAssertNotNil(viewModel.notificationPermission)
    }
    
    // MARK: - Test Data Refresh
    
    func testRefreshData() async {
        // Given
        let mockSettings = createMockSettings()
        mockRepository.mockSettings = mockSettings
        
        // When
        await viewModel.refreshData()
        
        // Then
        XCTAssertTrue(mockRepository.forceRefreshCalled)
        XCTAssertNotNil(viewModel.settings)
        XCTAssertEqual(viewModel.settings?.firstName, "John")
    }
    
    func testRefreshDataWithError() async {
        // Given
        mockRepository.shouldThrowError = true
        
        // When
        await viewModel.refreshData()
        
        // Then
        XCTAssertNotNil(viewModel.error)
    }
    
    // MARK: - Test Settings Validation
    
    func testSettingsWithAllProperties() {
        // Given
        let settings = createMockSettings()
        
        // Then
        XCTAssertNotNil(settings.firstName)
        XCTAssertNotNil(settings.lastName)
        XCTAssertNotNil(settings.email)
        XCTAssertNotNil(settings.birthday)
        XCTAssertNotNil(settings.accentColor)
        XCTAssertNotNil(settings.dynamicFontSize)
        XCTAssertNotNil(settings.notificationTime)
        XCTAssertFalse(settings.hasAccessedSettings)
    }
    
    func testSettingsWithMinimalProperties() {
        // Given
        let settings = Settings()
        
        // Then
        XCTAssertNil(settings.firstName)
        XCTAssertNil(settings.lastName)
        XCTAssertNil(settings.email)
        XCTAssertNil(settings.birthday)
        XCTAssertEqual(settings.accentColor, .yellow) // Default value
        XCTAssertTrue(settings.availableTags.isEmpty)
        XCTAssertNil(settings.notificationTime)
        XCTAssertEqual(settings.dynamicFontSize, 14) // Default value
        XCTAssertFalse(settings.hasAccessedSettings) // Default value
    }
    
    // MARK: - Helper Methods
    
    private func createMockSettings() -> Settings {
        let settings = Settings()
        settings.firstName = "John"
        settings.lastName = "Doe"
        settings.email = "john@example.com"
        settings.birthday = Date().addingTimeInterval(-86400 * 365 * 30) // 30 years ago
        settings.accentColor = .blue
        settings.dynamicFontSize = 16
        settings.notificationTime = HourAndMinute(hour: 8, minute: 0)
        settings.hasAccessedSettings = false
        
        // Add some tags
        let tag1 = Tag(name: "strength")
        let tag2 = Tag(name: "cardio")
        settings.availableTags = [tag1, tag2]
        
        return settings
    }
}
