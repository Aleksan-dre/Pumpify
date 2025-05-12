//
// HomeComponents.swift
//  Pumpify
//
//  Created by Timur Smoev on 12.05.25.

import SwiftUI

struct StatsCardView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Weekly Progress")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("70%")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Keep going, you're doing great!")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding()
                
                Spacer()
                
                CircularProgressView(progress: 0.7)
                    .frame(width: 80, height: 80)
                    .padding(.trailing)
            }
            .padding(.vertical, 8)
        }
        .frame(height: 140)
    }
}

struct CircularProgressView: View {
    var progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.3)
                .foregroundColor(.white)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(.white)
                .rotationEffect(Angle(degrees: 270))
                .animation(.linear, value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

struct SectionHeaderView: View {
    var title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            Button("See All") {
                // Action for see all button
            }
            .font(.subheadline)
            .foregroundColor(.blue)
        }
    }
}

struct WorkoutCardView: View {
    var title: String
    var duration: String
    var intensity: String
    var iconName: String
    
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: iconName)
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    
                    HStack {
                        Label(duration, systemImage: "clock")
                        Spacer()
                        Label(intensity, systemImage: "flame")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    // Action for starting workout
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "play.fill")
                            .foregroundColor(.white)
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

struct ActivityItemView: View {
    var activityName: String
    var date: String
    var duration: String
    var iconName: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 46, height: 46)
                
                Image(systemName: iconName)
                    .foregroundColor(.gray)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activityName)
                    .font(.headline)
                
                Text(date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(duration)
                .foregroundColor(.gray)
                .font(.subheadline)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        )
    }
}

struct RecommendedWorkoutView: View {
    var name: String
    var duration: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 46, height: 46)
                
                Image(systemName: "figure.mixed.cardio")
                    .foregroundColor(color)
                    .font(.system(size: 20))
            }
            
            Text(name)
                .font(.headline)
            
            Text(duration)
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
