//
//  SearchResult.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 29.06.25.
//

import Foundation

struct SearchResult: Identifiable {
    var id: UUID = UUID()
    
    var workout: Workout
    var exercises: Set<Exercise>
    var tags: Set<String>
    var findReasons: Set<SearchResultFindReason>
}

enum SearchResultFindReason: Hashable {
    case workout
    case exercise(UUID)
    case tag(String)
}
