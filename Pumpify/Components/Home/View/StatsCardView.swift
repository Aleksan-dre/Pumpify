//
//  ActivityItemView.swift
//  Pumpify
//
//  Created by Timur Smoev on 12.05.25.

import SwiftUI

struct StatsCardView: View {
    let stats: Stats

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
                    Text(stats.title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("\(Int(stats.progress * 100))%")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)

                    Text(stats.message)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding()

                Spacer()

                CircularProgressView(progress: stats.progress)
                    .frame(width: 80, height: 80)
                    .padding(.trailing)
            }
            .padding(.vertical, 8)
        }
        .frame(height: 140)
    }
}
