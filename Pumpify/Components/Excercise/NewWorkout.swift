//
//  NewWorkout.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 28.06.25.
//

import SwiftUI
import SwiftData

struct NewWorkout: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @Query() var existingWorkouts: [Workout]
    
    @State private var name: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Workout Name")) {
                    TextField("", text: $name)
                    if existingWorkouts.contains(where: { $0.name.lowercased() == name.lowercased() }) {
                        Text("A project with the same name already exists").foregroundStyle(.red)
                    }
                }
            }
        }
        .navigationBarTitle("New Workout")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    let workout = Workout(name: name, startDate: .now, priority: 2)
                    context.insert(workout)
                    dismiss()
                    try! context.save()
                }
                .disabled(name.isEmpty || existingWorkouts.contains(where: { $0.name.lowercased() == name.lowercased() }))
            }
        }
    }
}
