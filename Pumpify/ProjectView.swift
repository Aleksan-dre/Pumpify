//
//  ProjectView.swift
//  Pumpify
//
//  Created by Timur Smoev on 12.05.25.
//

import SwiftUI

struct ProjectView: View {
    @State private var workoutPlans: [String] = ["Morning Routine", "Strength Training", "Weight Loss Plan"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Project view will be implemented here
                // This is a placeholder for now
                Text("Training Plans")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("My Training Plans")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action to create new training plan
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    ProjectView()
}
