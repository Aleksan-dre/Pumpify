//
//  ExerciseCell.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 29.06.25.
//

import SwiftUI

struct WorkoutCell: View {
    var workout: Workout
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color(UIColor.secondarySystemGroupedBackground))
            .overlay(
                Text(workout.name)
                    .foregroundColor(.primary)
            )
    }
}
