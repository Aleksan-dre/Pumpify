//
//  ActivityItemView.swift
//  Pumpify
//
//  Created by Timur Smoev on 12.05.25.

import SwiftUI

struct SectionHeaderView: View {
    var title: String
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            if let action = action {
                Button("See All") {
                    action()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
        }
    }
}
