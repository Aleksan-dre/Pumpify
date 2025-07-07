//
//  TagChoice.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 29.06.25.
//

import SwiftUI

struct TagChoice: View {
    let initial: [String]
    let onTagsSelected: ([String]) -> Void
    
    @State private var selectedTags: Set<String> = []
    @State private var newTag: String = ""
    
    // Predefined tags
    private let predefinedTags = ["Chest", "Back", "Legs", "Arms", "Shoulders", "Cardio", "Core", "Strength", "Flexibility", "Endurance"]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Available Tags")) {
                    ForEach(predefinedTags, id: \.self) { tag in
                        Button(action: {
                            if selectedTags.contains(tag) {
                                selectedTags.remove(tag)
                            } else {
                                selectedTags.insert(tag)
                            }
                        }) {
                            HStack {
                                Text(tag)
                                Spacer()
                                if selectedTags.contains(tag) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                Section(header: Text("Add Custom Tag")) {
                    HStack {
                        TextField("Enter tag name", text: $newTag)
                        Button("Add") {
                            if !newTag.isEmpty && !selectedTags.contains(newTag) {
                                selectedTags.insert(newTag)
                                newTag = ""
                            }
                        }
                        .disabled(newTag.isEmpty)
                    }
                }
                
                if !selectedTags.isEmpty {
                    Section(header: Text("Selected Tags")) {
                        ForEach(Array(selectedTags), id: \.self) { tag in
                            HStack {
                                Text(tag)
                                Spacer()
                                Button("Remove") {
                                    selectedTags.remove(tag)
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Choose Tags")
            .navigationBarItems(
                leading: Button("Cancel") {
                    onTagsSelected(initial)
                },
                trailing: Button("Done") {
                    onTagsSelected(Array(selectedTags))
                }
            )
        }
        .onAppear {
            selectedTags = Set(initial)
        }
    }
}
