//
//  CalendarView.swift
//  Pumpify
//
//  Created by Timur Smoev on 12.05.25.
//

import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                // Calendar will be implemented here
                // This is a placeholder for now
                Text("Calendar View")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Workout Calendar")
        }
    }
}

#Preview {
    CalendarView()
}
