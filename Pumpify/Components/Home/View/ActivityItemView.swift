//
//  ActivityItemView.swift
//  Pumpify
//
//  Created by Timur Smoev on 12.05.25.
//  Home/View/ActivityItemView.swift

import SwiftUI

struct ActivityItemView: View {
    let activity: Activity

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 46, height: 46)

                Image(systemName: activity.iconName)
                    .foregroundColor(.gray)
                    .font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(activity.activityName)
                    .font(.headline)

                Text(activity.date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(activity.duration)
                .foregroundColor(.gray)
                .font(.subheadline)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        )
    }
}
