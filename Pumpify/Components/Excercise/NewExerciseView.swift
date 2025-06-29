//
//  NewExerciseView.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 29.06.25.
//

import SwiftUI
import SwiftData

struct NewExerciseView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    @Query var settingsList: [Settings]
    var settings: Settings? { settingsList.first }
    
    var workout: Workout
    @State private var name: String = ""
    @State private var startDate: Date = .now
    @State private var priority: Int = 2
    @State private var newTag: String = ""
    @State private var tags: [String] = []
    @State private var showNewTagPopup = false
    @State private var repeatDays = Set<DayOfWeek>()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Exercise")) {
                    TextField("Name", text: $name)
                    if workout.exercises.contains(where: { $0.name.lowercased() == name.lowercased() }) {
                        Text("A exercise with the same name already exists").foregroundStyle(.red)
                    }
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    NavigationLink {
                        RepeatDaysChoice(repeatDays: $repeatDays)
                    } label: {
                        HStack(alignment: .lastTextBaseline) {
                            Text("Repeat")
                            Spacer()
                            if repeatDays.isEmpty {
                                Text("Never")
                            } else if repeatDays == Set<DayOfWeek>([.monday, .tuesday, .wednesday, .thursday, .friday]) {
                                Text("Every Weekday")
                            } else if repeatDays == Set<DayOfWeek>([.saturday, .sunday]) {
                                Text("Every Weekend Day")
                            } else if repeatDays == Set(DayOfWeek.all) {
                                Text("Every Day")
                            } else {
                                Text(
                                    repeatDays
                                        .sorted(by: { $0.rawValue < $1.rawValue })
                                        .lazy
                                        .map { $0.shortString }
                                        .joined(separator: ", ")
                                )
                            }
                        }
                    }
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        Text("Meh").tag(1)
                        Text("Maybe").tag(2)
                        Text("Must").tag(3)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Tags")) {
                    ForEach(0..<tags.count, id: \.self) { index in
                        Text(tags[index])
                    }
                    .onDelete { indexSet in
                        tags.remove(atOffsets: indexSet)
                    }
                    Button(action: {
                        showNewTagPopup.toggle()
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
                let newExercise = Exercise(name: name, tags: tags, startDate: startDate, priority: 2, repeatDays: repeatDays)
                workout.exercises.append(newExercise)
                try! context.save()
                dismiss()
            }.disabled(name.isEmpty || workout.exercises.contains { $0.name.lowercased() == name.lowercased() })
        )
        .sheet(isPresented: $showNewTagPopup) {
            TagChoice(initial: tags, onTagsSelected: { selectedTags in
                showNewTagPopup = false
                tags.removeAll()
                tags.append(contentsOf: selectedTags)
            })
            .accentColor(settings?.accentColor.swiftuiAccentColor ?? .yellow)
        }
    }
}
