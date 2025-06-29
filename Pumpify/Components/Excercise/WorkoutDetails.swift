//
//  WorkoutDetails.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 29.06.25.
//

import SwiftUI

struct WorkoutDetails: View {
    var workout: Workout
    var exercise: Exercise
    @State private var name: String = .empty
    
    var body: some View {
        Form {
            
            Section(header: Text("Time")) {
                Text(exercise.startDate, style: .date)
            }
            
            Section(header: Text("Priority")) {
                Text("Priority:  \(exercise.priority)")
            }
            
            Section(header: Text("Repeat")) {
                ForEach(Array(exercise.repeatDays.sorted { $0.rawValue < $1.rawValue }), id: \.rawValue) {day in
                    Text(day.string)
                }
            }
            
            Section(header: Text("Tags")) {
                ForEach(exercise.tags, id: \.self) { tag in
                    Text(tag)
                }
            }
            

        }
        .navigationBarTitle(exercise.name)
        .navigationBarItems(
            trailing:
                NavigationLink(destination: EditExerciseDetailsView(workout: workout, exercise: exercise)) {
                    Text("Edit")
                }
        )
    }
}
