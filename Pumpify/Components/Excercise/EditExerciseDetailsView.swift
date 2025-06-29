//
//  EditExerciseDetailsView.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 29.06.25.
//

import SwiftUI
import SwiftData

struct EditExerciseDetailsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    @Query var settingsList: [Settings]
    var settings: Settings? { settingsList.first }

    var workout: Workout
    @State var exercise: Exercise
    
    @State var showNewTagPopup = false
    
    init(workout: Workout, exercise: Exercise) {
        self.workout = workout
        self._exercise = State(wrappedValue: exercise)
    }
    
    private func exerciseBinding<T>(for keyPath: WritableKeyPath<Exercise, T>) -> Binding<T> {
        Binding(
            get: { self.exercise[keyPath: keyPath] },
            set: { newValue in
                self.exercise[keyPath: keyPath] = newValue
            }
        )
    }
 
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Exercise")) {
                    TextField("Name", text: exerciseBinding(for: \.name))
                    DatePicker("Start Date", selection: exerciseBinding(for: \.startDate))
                }
                
                Section("Priority") {
                    Picker("Priority", selection: exerciseBinding(for: \.priority)) {
                        Text("Meh").tag(1)
                        Text("Maybe").tag(2)
                        Text("Must").tag(3)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Repeat")){
                    NavigationLink {
                        RepeatDaysChoice(repeatDays: exerciseBinding(for: \.repeatDays))
                    } label: {
                        HStack(alignment: .lastTextBaseline) {
                            Text("Repeat")
                            Spacer()
                            if exercise.repeatDays.isEmpty {
                                Text("Never")
                            } else if exercise.repeatDays == Set<DayOfWeek>([.monday, .tuesday, .wednesday, .thursday, .friday]) {
                                Text("Every Weekday")
                            } else if exercise.repeatDays == Set<DayOfWeek>([.saturday, .sunday]) {
                                Text("Every Weekend Day")
                            } else if exercise.repeatDays == Set(DayOfWeek.all) {
                                Text("Every Day")
                            } else {
                                Text(
                                    exercise.repeatDays
                                        .sorted(by: { $0.rawValue < $1.rawValue })
                                        .lazy
                                        .map { $0.shortString }
                                        .joined(separator: ", ")
                                )
                            }
                        }
                    }
                }
                
                Section(header: Text("Tags")) {
                    ForEach(0..<exercise.tags.count, id: \.self) { index in
                        Text(exercise.tags[index])
                    }
                    .onDelete { indexSet in
                        exercise.tags.remove(atOffsets: indexSet)
                    }
                    
                    Button(action: {
                        showNewTagPopup.toggle()
                    }) {
                        Text("Add tag")
                    }
                }
            }
        }
        .navigationBarTitle("Edit Exercise")
        .sheet(isPresented: $showNewTagPopup) {
            TagChoice(initial: exercise.tags, onTagsSelected: { selectedTags in
                showNewTagPopup = false
                exercise.tags.removeAll()
                exercise.tags.append(contentsOf: selectedTags)
            })
            .accentColor(settings?.accentColor.swiftuiAccentColor ?? .yellow)
        }
    }
}
