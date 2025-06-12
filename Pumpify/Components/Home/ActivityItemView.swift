//
//  ActivityItemView.swift
//  Pumpify
//
//  Created by TimurSmoev on 6/12/25.
//

import SwiftUI

struct ActivityItemView: View {
    var activityName: String
    var date: String
    var duration: String
    var iconName: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 46, height: 46)
                
                Image(systemName: iconName)
                    .foregroundColor(.gray)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activityName)
                    .font(.headline)
                
                Text(date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(duration)
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
