//
//  WorkoutCardView.swift
//  Pumpify
//
//  Created by TimurSmoev on 6/12/25.
//

import SwiftUI

struct WorkoutCardView: View {
    var title: String
    var duration: String
    var intensity: String
    var iconName: String
    
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: iconName)
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    
                    HStack {
                        Label(duration, systemImage: "clock")
                        Spacer()
                        Label(intensity, systemImage: "flame")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    // Action for starting workout
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "play.fill")
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
        }
    }
}
