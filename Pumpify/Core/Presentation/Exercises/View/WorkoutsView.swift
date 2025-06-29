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
                                NewWorkout()
                            }
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(viewModel.workouts) { workout in
                                NavigationLink(destination: WorkoutContent(workout: workout)) {
                                    WorkoutCell(workout: workout)
                                }
                            }
                            .onDelete(perform: viewModel.delete)
                        }
                       //.padding()
                    }
                } else if viewModel.searchTerm.isEmpty {
                    Text("Start typing to search")
                } else {
                    List(viewModel.searchResults) { result in
                        NavigationLink {
                            WorkoutContent(workout: result.workout)
                        } label: {
                            WorkoutSearchResultView(result: result)
                        }
                    }
                }
            }
            .navigationTitle("Workouts")
            .navigationBarItems(trailing:
                NavigationLink(destination: NewWorkout()) {
                    Image(systemName: "plus")
                }
            )
            .searchable(text: $viewModel.searchTerm, isPresented: $viewModel.isSearching)
            .task {
                await viewModel.loadExercises()
            }
        }
    }
}
