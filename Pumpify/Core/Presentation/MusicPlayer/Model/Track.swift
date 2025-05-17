//
//  Track.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 17.05.25.
//

import Foundation

/// Model representing a single audio track
struct Track: Identifiable {
    let id = UUID()
    let url: URL
    var title: String { url.deletingPathExtension().lastPathComponent }
}
