//
//  SectionHeaderView.swift
//  Pumpify
//
//  Created by TimurSmoev on 6/12/25.
//

import SwiftUI

struct SectionHeaderView: View {
    var title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            Button("See All") {
                // Action for see all button
            }
            .font(.subheadline)
            .foregroundColor(.blue)
        }
    }
}
