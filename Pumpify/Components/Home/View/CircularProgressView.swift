//
//  ActivityItemView.swift
//  Pumpify
//
//  Created by Timur Smoev on 09.06.25.
//  Home/View/ActivityItemView.swift

import SwiftUI

struct CircularProgressView: View {
    var progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.3)
                .foregroundColor(.white)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(.white)
                .rotationEffect(Angle(degrees: 270))
                .animation(.linear, value: progress)

            Text("\(Int(progress * 100))%")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
    }
}
