//
//  MusicPlayerViewModel.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 17.05.25.
//

import Foundation
import Combine
import UniformTypeIdentifiers

final class MusicPlayerViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var trackTitle: String = ""
    @Published var playList: [Track] = []

    private var audio = AudioManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        audio.$isPlaying
            .receive(on: DispatchQueue.main)
            .assign(to: &$isPlaying)

        audio.$currentTime
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentTime)

        audio.$duration
            .receive(on: DispatchQueue.main)
            .assign(to: &$duration)

        audio.$currentTrack
            .compactMap { $0?.title }
            .receive(on: DispatchQueue.main)
            .assign(to: &$trackTitle)
    }

    // MARK: - Exposed Actions
    func loadTracks(urls: [URL]) {
        let tracks = urls.map(Track.init)
        audio.load(tracks: tracks)
    }

    func playPause() {
        isPlaying ? audio.pause() : audio.play()
    }

    func next() {
        audio.nextTrack()
    }

    func previous() {
        audio.previousTrack()
    }

    func seek(to time: Double) {
        audio.seek(to: time)
    }
    
    func playTrack(at index: Int) {
        audio.playTrack(at: index)
    }
    
    var tracks: [Track] {
        audio.getTracks()
    }
}
