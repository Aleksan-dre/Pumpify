//
//  HomeView.swift
//  Pumpify
//
//  Created by Timur Smoev on 12.05.25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header welcome section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hello, User!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Ready for your workout today?")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top)
                    
                    // Stats Card
                    StatsCardView()
                    
                    // Today's workout section
                    SectionHeaderView(title: "Today's Workout")
                    
                    WorkoutCardView(
                        title: "Full Body Blast",
                        duration: "45 min",
                        intensity: "Medium",
                        iconName: "bolt.fill"
                    )
                    
                    // Recent activities section
                    SectionHeaderView(title: "Recent Activities")
                    
                    VStack(spacing: 16) {
                        ActivityItemView(
                            activityName: "Morning Run",
                            date: "Yesterday",
                            duration: "30 min",
                            iconName: "figure.run"
                        )
                        
                        ActivityItemView(
                            activityName: "Upper Body",
                            date: "2 days ago",
                            duration: "40 min",
                            iconName: "dumbbell.fill"
                        )
                    }
                    
                    // Recommended workouts section
                    SectionHeaderView(title: "Recommended For You")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            RecommendedWorkoutView(
                                name: "HIIT Cardio",
                                duration: "20 min",
                                color: .orange
                            )
                            
                            RecommendedWorkoutView(
                                name: "Core Power",
                                duration: "15 min",
                                color: .blue
                            )
                            
                            RecommendedWorkoutView(
                                name: "Leg Day",
                                duration: "30 min",
                                color: .purple
                            )
                        }
                        .padding(.bottom, 10)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action for notifications
                    }) {
                        Image(systemName: "bell.badge")
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action for profile
                    }) {
                        Image(systemName: "person.circle")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
}

#Preview {
    HomeView()
}
