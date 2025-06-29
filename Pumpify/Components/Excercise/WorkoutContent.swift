//
//  ExerciseContent.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 28.06.25.
//

import SwiftUI
import SwiftData

/// Displays content for a specific workout, including workouts and options to add, delete, or move exercises.
struct WorkoutContent: View {
    @Environment(\.modelContext) var modelContext
    
    @Query var settingsList: [Settings]
    var settings: Settings? { settingsList.first }
    
    var workout: Workout
    @State private var isEditing = false
    @State private var selection = Set<UUID>()
    
    @State private var deleteDialogVisible = false
    @State private var moveDialogVisible = false
    
    @Environment(\.editMode) var editMode
    
    var body: some View {
        NavigationStack {
            if (workout.exercises.isEmpty) {
                VStack {
                    Spacer()
                    Text("There are no exercises.")
                    NavigationLink("Add new exercise") {
                        NewExerciseView(workout: workout)
                    }
                    Spacer()
                }
            }
            
            List(workout.exercises, selection: $selection) { exercise in
                NavigationLink(destination: WorkoutDetails(workout: workout, exercise: exercise)) {
                    Text(exercise.name)
                }
            }
            
        }
        .navigationTitle(workout.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if editMode!.wrappedValue == .inactive {
                        NavigationLink(destination: NewExerciseView(workout: workout)) {
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
                        
                        Button {
                            moveDialogVisible = true
                        } label: {
                            Text("Move")
                        }
                        .disabled(selection.isEmpty)
                        .sheet(
                            isPresented: $moveDialogVisible
                        ) {
                            ChooseWorkoutView(title: "Choose Workout") { newWorkout in
                                guard let newWorkout = newWorkout else { return }
                                let exercisesToMove = workout.exercises.filter { selection.contains($0.id) }
                                workout.exercises.removeAll { selection.contains($0.id) }
                                newWorkout.exercises.append(contentsOf: exercisesToMove)
                                selection.removeAll()
                            }
                            .accentColor(settings?.accentColor.swiftuiAccentColor ?? .yellow)
                        }
                    }
                    EditButton()
                }
            }
        }
    }
    
    func deleteExercises(at offsets: IndexSet) {
        for offset in offsets {
            let exercise = workout.exercises[offset]
            if let dataForExercise = try? modelContext.fetch(FetchDescriptor<StopwatchData>()) {
                let filtered = dataForExercise.filter { $0.exerciseId == exercise.id }
                for data in filtered {
                    modelContext.delete(data)
                }
            }
            modelContext.delete(exercise)
        }
        workout.exercises.remove(atOffsets: offsets)
    }
}

/// View for selecting a project to move exercises to.
struct ChooseWorkoutView: View {
    var title: String
    var onWorkoutChosen: (Workout?) -> ()
    
    @Query var projects: [Workout]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Text(title)
            .font(.title)
            .padding()
        
        List(projects) { project in
            Button {
                dismiss()
                onWorkoutChosen(project)
            } label: {
                Text(project.name)
            }
        }
    }
}
