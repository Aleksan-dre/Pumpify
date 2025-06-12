//
//  StatsCardView.swift
//  Pumpify
//
//  Created by TimurSmoev on 6/12/25.
//

import SwiftUI

struct StatsCardView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Weekly Progress")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("70%")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Keep going, you're doing great!")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding()
                
                Spacer()
                
                CircularProgressView(progress: 0.7)
                    .frame(width: 80, height: 80)
                    .padding(.trailing)
            }
            .padding(.vertical, 8)
        }
        .frame(height: 140)
    }
}
