//
//  ShapeStyle+Extension.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 12.05.25.
//

import SwiftUI

extension ShapeStyle where Self == Color {
    // MARK: - Neutral
    public static var neutralBlack: Color { Color(hex: 0x1A120B) }
    public static var neutralWhite: Color { Color(hex: 0xFFFFFF) }
    
    // MARK: - Orange
    // TODO: Replace hex numbers with orange hex colors
    public static var yellowPrimary: Color { Color(hex: 0xFFBC1F) }
    public static var yellowSecondary: Color { Color(hex: 0xFFE588) }
    public static var yellowTertiary: Color { Color(hex: 0xF09029) }
    public static var yellowDark: Color { Color(hex: 0x7B330C) }
    public static var yellowExtraDark: Color { Color(hex: 0x461902) }
    
    // MARK: - Gray
    public static var grayPrimary: Color { Color(hex: 0x545454) }
    public static var graySecondary: Color { Color(hex: 0x999999) }
    public static var grayTertiary: Color { Color(hex: 0xD1D1D1) }
    public static var grayLight: Color { Color(hex: 0xE9E9E9) }
    public static var grayExtraLight: Color { Color(hex: 0xF0F0F0) }
    public static var grayExtraLight2: Color { Color(hex: 0xF9F9F9) }
    
    // MARK: - System
    public static var systemError: Color { Color(hex: 0xFF3B30) }
    public static var systemSuccess: Color { Color(hex: 0x4CAF50) }
    public static var systemWarning: Color { Color(hex: 0xFFBB33) }
    public static var systemLink: Color { Color(hex: 0x007AFF) }
}
