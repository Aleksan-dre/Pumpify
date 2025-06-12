//
//  Track.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 17.05.25.
//

import Foundation

/// Model representing a single audio track
struct Track: Identifiable, Hashable, Equatable {
    let id = UUID()
    let url: URL
    
    init(url: URL) {
        _ = url.startAccessingSecurityScopedResource()
        self.url = url
    }
    
    var title: String { 
        url.deletingPathExtension().lastPathComponent 
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.url == rhs.url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

extension URL {
    func bookmarkData() -> Data {
        do {
            return try self.bookmarkData(
                options: .minimalBookmark,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
        } catch {
            print("Failed to create bookmark: \(error)")
            return Data()
        }
    }
    
    init?(bookmarkData data: Data) {
        var isStale = false
        do {
            try self.init(
                resolvingBookmarkData: data,
                bookmarkDataIsStale: &isStale
            )
            if isStale {
                print("Warning: Bookmark data is stale")
            }
            _ = startAccessingSecurityScopedResource()
        } catch {
            print("Failed to resolve bookmark: \(error)")
            return nil
        }
    }
}
