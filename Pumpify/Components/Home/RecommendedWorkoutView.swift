//
//  RecommendedWorkoutView.swift
//  Pumpify
//
//  Created by TimurSmoev on 6/12/25.
//

import SwiftUI

struct RecommendedWorkoutView: View {
    var name: String
    var duration: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 46, height: 46)
                
                Image(systemName: "figure.mixed.cardio")
                    .foregroundColor(color)
                    .font(.system(size: 20))
            }
            
            Text(name)
                .font(.headline)
            
            Text(duration)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 140)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}
