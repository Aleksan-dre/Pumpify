//
//  Settings.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 27.06.25.
//

import SwiftUI
import SwiftData

@Model
class Settings {
    var firstName: String?
    var lastName: String?
    var email: String?
    var birthday: Date?
    var accentColor: AccentColor
    var availableTags: [Tag]
    var notificationTime: HourAndMinute?
    var dynamicFontSize: CGFloat?
    var hasAccessedSettings: Bool = false
    
    init() {
        self.accentColor = .yellow
        self.availableTags = []
        self.dynamicFontSize = 14
        self.hasAccessedSettings = false
    }
}

@Model
class Tag {
    var name: String
    init(name: String){
        self.name = name
    }
}

struct HourAndMinute: Codable {
    var hour: Int
    var minute: Int
}

enum AccentColor: Codable {
    case red
    case green
    case blue
    case yellow
    case purple
}

extension AccentColor {
    var string: String {
        switch self {
        case .red: "Red"
        case .green: "Green"
        case .blue: "Blue"
        case .yellow: "Yellow"
        case .purple: "Purple"
        }
    }
    
    var swiftuiAccentColor: Color {
        switch self {
        case .red: .red
        case .green: .green
        case .blue: .blue
        case .yellow: .yellow
        case .purple: .purple
        }
    }
}
