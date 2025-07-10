//
//  ExerciseDetailsView.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 07.07.25.
//

import SwiftUI
import SwiftData

struct ExerciseDetailsView: View {
    @StateObject var viewModel: ExerciseDetailsViewModel
    private let date: Date
    
    init(date: Date, viewModel: ExerciseDetailsViewModel) {
        self.date = date
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(viewModel.exercises.indices, id: \.self) { index in
                exerciseItemView(viewModel.exercises[index])
            }
            
            if viewModel.exercises.isEmpty {
                Spacer()
                
                Text("No Exercises for this day")
                    .font(.title)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .navigationTitle("Exercises for \(DateFormatter.mediumDate.string(from: date))")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task {
                await viewModel.loadData()
            }
        }
        .refreshable {
            await viewModel.refreshData()
        }
        .loadingOverlay(for: viewModel)
        .errorAlert(for: viewModel)
        .alert("Exercise Already Completed", isPresented: $viewModel.showRestartStopwatchConfirmation) {
            Button("Add More Time", action: viewModel.confirmContinueStopwatch)
            Button("Cancel", role: .cancel, action: viewModel.cancelContinueStopwatch)
        } message: {
            Text("This exercise has already been completed today. Do you want to add more tracking time?")
        }
        .alert("Reset Exercise Time", isPresented: $viewModel.showResetConfirmation) {
            Button("Reset", role: .destructive, action: viewModel.confirmReset)
            Button("Cancel", role: .cancel, action: viewModel.cancelReset)
        } message: {
            Text("Are you sure you want to reset all tracked time for this exercise? This action cannot be undone.")
        }
    }

    private func exerciseItemView(_ exercise: Exercise) -> some View {
        let stopwatchData = viewModel.getStopwatchData(for: exercise)
        
        let label = VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(exercise.name)
                        .font(.headline)
                }
                Spacer()
                if let stopwatchData = stopwatchData {
                    VStack(spacing: 4) {
                        Text(String(format: "Time: %@", stopwatchData.totalInterval.formattedTime()))
                        
                        // Reset button for completed exercises
                        Button(action: {
                            viewModel.resetExerciseData(for: exercise)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.clockwise")
                                Text("Reset")
                            }
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange)
                            .cornerRadius(8)
                        }
                    }
                    .padding([.horizontal])
                }
                Image(systemName: stopwatchData != nil ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(stopwatchData != nil ? .green : .gray)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        
        return NavigationLink(
            destination: StopwatchViewFactory.make(
                exerciseId: exercise.id,
                date: date,
                updating: viewModel.continuingStopwatchDatum,
                repository: viewModel.repository
            ),
            isActive: $viewModel.navigatingToStopwatch,
            label: { label }
        )
        .onChange(of: viewModel.navigatingToStopwatch) { isNavigating in
            if !isNavigating {
                // User returned from stopwatch, refresh data
                Task {
                    await viewModel.loadData()
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
        .onTapGesture {
            viewModel.handleStopwatchNavigation(for: exercise)
        }
    }
}
