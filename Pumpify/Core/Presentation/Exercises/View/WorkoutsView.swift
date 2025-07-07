//
//  WorkoutsView.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 28.06.25.
//

import SwiftUI

struct WorkoutsView: View {
    @StateObject var viewModel: WorkoutsViewModel

    var body: some View {
        NavigationStack {
            Group {
                if !viewModel.isSearching {
                    if viewModel.workouts.isEmpty {
                        VStack {
                            Spacer()
                            Text("There are no workouts yet.")
                            NavigationLink("Add new workout") {
                                NewWorkoutViewFactory.make(repository: viewModel.repository)
                            }
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(viewModel.workouts) { workout in
                                NavigationLink(destination: WorkoutDetailsView(workout: workout, repository: viewModel.repository)) {
                                    WorkoutCell(workout: workout)
                                }
                            }
                            .onDelete { offsets in
                                Task {
                                    await viewModel.delete(at: offsets)
                                }
                            }
                        }
                       //.padding()
                    }
                } else if viewModel.searchTerm.isEmpty {
                    Text("Start typing to search")
                } else {
                    List(viewModel.searchResults) { result in
                        NavigationLink {
                            WorkoutDetailsView(workout: result.workout, repository: viewModel.repository)
                        } label: {
                            WorkoutSearchResultView(result: result)
                        }
                    }
                }
            }
            .navigationTitle("Workouts")
            .navigationBarItems(trailing:
                NavigationLink(destination: NewWorkoutViewFactory.make(repository: viewModel.repository)) {
                    Image(systemName: "plus")
                }
            )
            .searchable(text: $viewModel.searchTerm, isPresented: $viewModel.isSearching)
            .task {
                await viewModel.loadExercises()
            }
            .refreshable {
                await viewModel.refreshData()
            }
        }
        .loadingOverlay(for: viewModel)
        .errorAlert(for: viewModel)
    }
}
