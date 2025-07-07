//
//  NewExerciseView.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 07.07.25.
//

import SwiftUI

struct NewExerciseView: View {
    @StateObject var viewModel: NewExerciseViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Exercise")) {
                    TextField("Name", text: $viewModel.name)
                    DatePicker("Start Date", selection: $viewModel.startDate)
                }
                
                Section("Repeat") {
                    NavigationLink {
                        RepeatDaysChoice(repeatDays: $viewModel.repeatDays)
                    } label: {
                        HStack(alignment: .lastTextBaseline) {
                            Text("Repeat")
                            Spacer()
                            if viewModel.repeatDays.isEmpty {
                                Text("Never")
                            } else if viewModel.repeatDays == Set<DayOfWeek>([.monday, .tuesday, .wednesday, .thursday, .friday]) {
                                Text("Every Weekday")
                            } else if viewModel.repeatDays == Set<DayOfWeek>(DayOfWeek.all) {
                                Text("Every Day")
                            } else {
                                Text(
                                    viewModel.repeatDays
                                        .sorted { $0.rawValue < $1.rawValue }
                                        .map { $0.shortString }
                                        .joined(separator: ", ")
                                )
                            }
                        }
                    }
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $viewModel.priority) {
                        Text("Meh").tag(1)
                        Text("Maybe").tag(2)
                        Text("Must").tag(3)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Tags")) {
                    ForEach(0..<viewModel.tags.count, id: \.self) { index in
                        Text(viewModel.tags[index])
                    }
                    .onDelete { indexSet in
                        viewModel.removeTag(at: indexSet)
                    }
                    Button(action: {
                        viewModel.toggleTagPopup()
                    }) {
                        Text("Add tag")
                    }
                }
            }
        }
        .navigationBarTitle("New Exercise")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button("Cancel") {
                dismiss()
            },
            trailing: Button("Save") {
                Task {
                    let success = await viewModel.saveExercise()
                    if success {
                        dismiss()
                    }
                }
            }.disabled(!viewModel.isFormValid)
        )
        .sheet(isPresented: $viewModel.showNewTagPopup) {
            TagChoice(initial: viewModel.tags, onTagsSelected: { selectedTags in
                viewModel.showNewTagPopup = false
                viewModel.tags.removeAll()
                viewModel.tags.append(contentsOf: selectedTags)
            })
            .accentColor(viewModel.settings?.accentColor.swiftuiAccentColor ?? .yellow)
        }
        .loadingOverlay(for: viewModel)
        .errorAlert(for: viewModel)
        .accentColor(viewModel.settings?.accentColor.swiftuiAccentColor ?? .yellow)
    }
}
