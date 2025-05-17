//
//  MusicPlayerView.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 17.05.25.
//

import SwiftUI
import MediaPlayer
import AVFoundation

struct MusicPlayerView: View {
    @StateObject var viewModel: MusicPlayerViewModel
    @State private var showingPicker = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                header
                
                Spacer()
                
                player
                
                audioLIst
            }
        }
    }
}

private extension MusicPlayerView {
    var header: some View {
        HStack(spacing: .zero) {
            Spacer()
            Button {
                showingPicker = true
            } label: {
                Label("Import Files", systemImage: "folder")
            }
        }
        .font(.headline)
        .padding()
        .sheet(isPresented: $showingPicker) {
            DocumentPicker { urls in
                viewModel.loadTracks(urls: urls)
                showingPicker = false
            }
        }
    }
    
    func timeString(from seconds: Double) -> String {
        let total = Int(seconds)
        let mins = total / 60
        let secs = total % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    var player: some View {
        VStack(spacing: 16) {
            Text(viewModel.trackTitle)
                .font(.title2)
                .bold()
                .lineLimit(1)
                .padding(.horizontal)
            
            // add time labels around your existing slider
            HStack {
                Text(timeString(from: viewModel.currentTime))
                    .font(.caption)
                
                Slider(
                    value: Binding(
                        get: { viewModel.currentTime },
                        set: { newValue in viewModel.seek(to: newValue) }
                    ),
                    in: 0...max(viewModel.duration, 1)
                )
                
                Text(timeString(from: viewModel.duration))
                    .font(.caption)
            }
            .padding(.horizontal)
            
            HStack(spacing: .assets.xl4) {
                Button(action: viewModel.previous) {
                    Image(systemName: "backward.fill")
                        .font(.largeTitle)
                }
                Button(action: viewModel.playPause) {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.largeTitle)
                }
                Button(action: viewModel.next) {
                    Image(systemName: "forward.fill")
                        .font(.largeTitle)
                }
            }
            .padding(.top, 8)
        }
        .padding(.horizontal)
    }
    
    var audioLIst: some View {
        List(viewModel.tracks.indices, id: \.self) { index in
            Button(action: { viewModel.playTrack(at: index) }) {
                Text(viewModel.tracks[index].title)
            }
        }
    }
}
