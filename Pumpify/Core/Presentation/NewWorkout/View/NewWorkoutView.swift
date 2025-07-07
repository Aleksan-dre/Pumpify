//
//  NewWorkoutView.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 07.07.25.
//

import SwiftUI

struct NewWorkoutView: View {
    @StateObject var viewModel: NewWorkoutViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Workout Details")) {
                    TextField("Workout Name", text: $viewModel.name)
                    DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $viewModel.priority) {
                        Text("Meh").tag(1)
                        Text("Maybe").tag(2)
                        Text("Must").tag(3)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("New Workout")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            let success = await viewModel.saveWorkout()
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
        }
        .loadingOverlay(for: viewModel)
        .errorAlert(for: viewModel)
        .accentColor(viewModel.settings?.accentColor.swiftuiAccentColor ?? .yellow)
    }
}
