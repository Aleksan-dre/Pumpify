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
        .refreshable {
            await viewModel.refreshData()
        }
        .loadingOverlay(for: viewModel)
        .errorAlert(for: viewModel)
        .alert("Exercise Already Completed", isPresented: $viewModel.showRestartStopwatchConfirmation) {
            Button("Restart", action: viewModel.confirmRestartStopwatch)
            Button("Cancel", role: .cancel, action: viewModel.cancelRestartStopwatch)
        } message: {
            Text("This exercise has already been completed today. Do you want to restart the stopwatch?")
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
                    Text(String(format: "Time: %@", stopwatchData.totalInterval.formattedTime()))
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
        .onTapGesture {
            viewModel.handleStopwatchNavigation(for: exercise)
        }
    }
}
