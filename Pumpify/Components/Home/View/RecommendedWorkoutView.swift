//
//  ActivityItemView.swift
//  Pumpify
//
//  Created by Timur Smoev on 12.05.25.

import SwiftUI

struct RecommendedWorkoutView: View {
    let recommended: RecommendedWorkout

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(recommended.color.opacity(0.2))
                    .frame(width: 46, height: 46)

                Image(systemName: "figure.mixed.cardio")
                    .foregroundColor(recommended.color)
                    .font(.system(size: 20))
            }

            Text(recommended.name)
                .font(.headline)

            Text(recommended.duration)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 140)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}
