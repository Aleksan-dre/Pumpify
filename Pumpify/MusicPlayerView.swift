//
//  MusicPlayerView.swift
//  Pumpify
//
//  Created by Timur Smoev on 12.05.25.
//

import SwiftUI

struct MusicPlayerView: View {
    @State private var isPlaying = false
    @State private var progress: CGFloat = 0.3
    @State private var volume: CGFloat = 0.7
    
    var body: some View {
        NavigationView {
            VStack {
                // Music player will be implemented here
                // This is a placeholder for now
                Text("Music Player")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Workout Music")
        }
    }
}

#Preview {
    MusicPlayerView()
}
