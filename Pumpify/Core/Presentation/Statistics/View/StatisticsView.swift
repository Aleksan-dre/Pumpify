//
//  StatisticsView.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 11.07.2025.
//

import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @StateObject var viewModel: StatisticsViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Period Selector
                    periodSelectorView
                    
                    // Overview Cards
                    overviewCardsView
                    
                    // Progress Chart
                    progressChartView
                    
                    // Top Exercises
                    topExercisesView
                    
                    // Weekly Trend
                    weeklyTrendView
                    
                    // Additional Insights
                    additionalInsightsView
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .refreshable {
                await viewModel.refreshData()
            }
            .task {
                await viewModel.loadData()
            }
            .onAppear {
                Task {
                    await viewModel.loadData()
                }
            }
        }
        .loadingOverlay(for: viewModel)
        .errorAlert(for: viewModel)
    }
    
    // MARK: - Period Selector
    
    private var periodSelectorView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Time Period")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Picker("Period", selection: $viewModel.selectedPeriod) {
                ForEach(StatisticsPeriod.allCases) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Overview Cards
    
    private var overviewCardsView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatisticsCard(
                title: "Total Time",
                value: viewModel.totalTimeThisPeriod.formattedTime(),
                icon: "clock.fill",
                color: .blue
            )
            
            StatisticsCard(
                title: "Exercises",
                value: "\(viewModel.completedExercisesThisPeriod)",
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            StatisticsCard(
                title: "Daily Average",
                value: viewModel.averageTimePerDay.formattedTime(),
                icon: "calendar",
                color: .orange
            )
            
            StatisticsCard(
                title: "Streak",
                value: "\(viewModel.getCompletionStreak()) days",
                icon: "flame.fill",
                color: .red
            )
        }
    }
    
    // MARK: - Progress Chart
    
    private var progressChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Daily Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("Last \(viewModel.selectedPeriod.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !viewModel.dailyProgress.isEmpty {
                Chart(viewModel.dailyProgress, id: \.date) { item in
                    BarMark(
                        x: .value("Date", item.date),
                        y: .value("Time", item.totalTime / 60) // Convert to minutes
                    )
                    .foregroundStyle(.blue.gradient)
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel() {
                            if let minutes = value.as(Double.self) {
                                Text("\(Int(minutes))m")
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: max(1, viewModel.dailyProgress.count / 7))) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        Text("No data available")
                            .foregroundColor(.secondary)
                    )
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Top Exercises
    
    private var topExercisesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Top Exercises")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("By time spent")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !viewModel.topExercises.isEmpty {
                VStack(spacing: 8) {
                    ForEach(Array(viewModel.topExercises.enumerated()), id: \.offset) { index, item in
                        TopExerciseRow(
                            rank: index + 1,
                            exercise: item.exercise,
                            totalTime: item.totalTime
                        )
                    }
                }
            } else {
                Text("No exercises completed yet")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Weekly Trend
    
    private var weeklyTrendView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Weekly Trend")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            if !viewModel.weeklyComparison.isEmpty {
                Chart(viewModel.weeklyComparison, id: \.week) { item in
                    LineMark(
                        x: .value("Week", item.week),
                        y: .value("Hours", item.totalTime / 3600) // Convert to hours
                    )
                    .foregroundStyle(.green)
                    .symbol(.circle)
                    
                    PointMark(
                        x: .value("Week", item.week),
                        y: .value("Hours", item.totalTime / 3600)
                    )
                    .foregroundStyle(.green)
                }
                .frame(height: 150)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel() {
                            if let hours = value.as(Double.self) {
                                Text("\(hours, specifier: "%.1f")h")
                            }
                        }
                    }
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 150)
                    .overlay(
                        Text("No trend data available")
                            .foregroundColor(.secondary)
                    )
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Additional Insights
    
    private var additionalInsightsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                InsightRow(
                    icon: "star.fill",
                    title: "Most Active Day",
                    value: viewModel.mostActiveDay,
                    color: .yellow
                )
                
                InsightRow(
                    icon: "target",
                    title: "Goal Progress",
                    value: "\(Int(viewModel.getProgressPercentage() * 100))%",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views

struct StatisticsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct TopExerciseRow: View {
    let rank: Int
    let exercise: Exercise
    let totalTime: TimeInterval
    
    var body: some View {
        HStack {
            // Rank badge
            Text("\(rank)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(rankColor)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if !exercise.tags.isEmpty {
                    Text(exercise.tags.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(totalTime.formattedTime())
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
}

struct InsightRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
