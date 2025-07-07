//
//  WorkoutSearchResultView.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 29.06.25.
//

import SwiftUI

struct WorkoutSearchResultView: View {
    var result: SearchResult
    
    var body: some View {
        VStack(alignment: .leading) {
            if result.findReasons.contains(.workout) {
                Text(result.workout.name)
                    .foregroundStyle(Color.accentColor)
                    .font(.title)
            } else {
                Text(result.workout.name)
                    .font(.title)
            }
            ForEach(Array(result.exercises.sorted { $0.id < $1.id })) { exercise in
                VStack(alignment: .leading) {
                    if result.findReasons.contains(.exercise(exercise.id)) {
                        Text("Exercise: \(exercise.name)")
                            .foregroundStyle(Color.accentColor)
                    } else {
                        Text("Exercise: \(exercise.name)")
                    }
                    
                    let foundTags = exercise.tags.filter { result.tags.contains($0) }
                    if !foundTags.isEmpty {
                        Group {
                            Text("Tags: ") + Text(foundTags.joined(separator: ", ")).foregroundStyle(Color.accentColor)
                        }
                        .padding(.leading)
                    }
                }
                .padding(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
