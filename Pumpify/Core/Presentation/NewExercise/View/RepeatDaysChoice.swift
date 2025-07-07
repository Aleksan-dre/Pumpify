//
//  RepeatDaysChoice.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 29.06.25.
//

import SwiftUI

struct RepeatDaysChoice: View {
    @Binding var repeatDays: Set<DayOfWeek>
    
    var body: some View {
        List {
            ForEach(DayOfWeek.all, id: \.self) { day in
                let isChecked = repeatDays.contains(day)
                Button(action: {
                    if isChecked {
                        repeatDays.remove(day)
                    } else {
                        repeatDays.insert(day)
                    }
                }) {
                    CheckboxView(title: day.string, isChecked: isChecked)
                }
            }
        }
        .navigationTitle("Repeat Days")
    }
}

struct CheckboxView: View {
    let title: String
    let isChecked: Bool
    
    var body: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: isChecked ? "checkmark.square" : "square")
            }
            Text(title)
        }
    }
}
