//
//  HomeViewModel.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 27.06.25.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Query private var settingsList: [Settings]

    var settings: Settings? {
        settingsList.first
    }

    var welcomeTitle: String {
        settings?.firstName.map {
            String(format: NSLocalizedString("WelcomeWithName", comment: "Welcome message with user's name"), $0)
        } ?? NSLocalizedString("Welcome", comment: "Generic welcome message")
    }

    init() {
        // Default init for @Query to work
    }
}
