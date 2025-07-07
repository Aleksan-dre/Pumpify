//
//  WorkoutDetailsView.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 28.06.25.
//

import SwiftUI

struct WorkoutDetailsView: View {
    let workout: Workout
    let repository: any DataRepositoryProtocol
    @State private var isEditing = false
    @State private var selection = Set<UUID>()
    
    @State private var deleteDialogVisible = false
    @State private var moveDialogVisible = false
    
    @Environment(\.editMode) var editMode
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            if (workout.exercises.isEmpty) {
                VStack {
                    Spacer()
                    Text("There are no exercises.")
                    NavigationLink("Add new exercise") {
                        NewExerciseViewFactory.make(workout: workout, repository: repository)
                    }
                    Spacer()
                }
            } else {
                List(workout.exercises, selection: $selection) { exercise in
                    NavigationLink(destination: ExerciseDetailsViewFactory.make(date: Date(), repository: repository)) {
                        Text(exercise.name)
                    }
                }
            }
        }
        .navigationTitle(workout.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if editMode!.wrappedValue == .inactive {
                        NavigationLink(destination: NewExerciseViewFactory.make(workout: workout, repository: repository)) {
                            Image(systemName: "plus")
                        }
                    } else {
                        Button {
                            deleteDialogVisible = true
                        } label: {
                            Image(systemName: "trash")
                        }
                        .disabled(selection.isEmpty)
                        .confirmationDialog(
                            "Are you sure you want to delete \(selection.count) exercises?",
                            isPresented: $deleteDialogVisible,
                            titleVisibility: .visible
                        ) {
                            Button("Delete", role: .destructive) {
                                let exercisesToDelete = workout.exercises.filter { selection.contains($0.id) }
                                workout.exercises.removeAll { selection.contains($0.id) }
                                
                                for exercise in exercisesToDelete {
                                    modelContext.delete(exercise)
                                }
                                selection.removeAll()
                            }
                        }
                    }
                    EditButton()
                }
            }
        }
    }
}
