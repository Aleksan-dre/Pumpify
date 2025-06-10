//
//  ActivityItemView.swift
//  Pumpify
//
//  Created by Timur Smoev on 12.05.25.

import SwiftUI

struct WorkoutCardView: View {
    let workout: Workout
    var onStart: (() -> Void)? = nil

    var body: some View {
        VStack {
            HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 50, height: 50)

                    Image(systemName: workout.iconName)
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.title)
                        .font(.headline)

                    HStack {
                        Label(workout.duration, systemImage: "clock")
                        Spacer()
                        Label(workout.intensity, systemImage: "flame")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }

                Spacer()

                if let onStart = onStart {
                    Button(action: onStart) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                                .frame(width: 40, height: 40)

                            Image(systemName: "play.fill")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
        }
    }
}

