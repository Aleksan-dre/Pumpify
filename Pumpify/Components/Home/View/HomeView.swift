//
//  ActivityItemView.swift
//  Pumpify
//
//  Created by Timur Smoev on 12.05.25.

// Home/View/HomeView.swift
import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Stats Card
                StatsCardView(stats: StatsFactory.makeWeeklyStats())

                // Section Header
                SectionHeaderView(title: "Workouts")

                // Workouts
                ForEach(WorkoutFactory.makeSampleWorkouts(), id: \.title) { workout in
                    WorkoutCardView(workout: workout)
                }

                // Section Header
                SectionHeaderView(title: "Recent Activities")

                // Activities
                ForEach(ActivityFactory.makeRecentActivities(), id: \.activityName) { activity in
                    ActivityItemView(activity: activity)
                }

                // Section Header
                SectionHeaderView(title: "Recommended")

                // Recommended
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(RecommendedWorkoutFactory.makeRecommendedWorkouts(), id: \.name) { item in
                            RecommendedWorkoutView(recommended: item)
                        }
                    }
                }
            }
            .padding()
        }
    }
}
