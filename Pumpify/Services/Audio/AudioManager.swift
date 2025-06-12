//
//  AudioManager.swift
//  Pumpify
//
//  Created by Aleksandre Shalikashvili on 17.05.25.
//

import Foundation
import AVFoundation
import MediaPlayer
import Combine

/// Singleton managing audio playback, background session, and remote control
final class AudioManager: ObservableObject {
    static let shared = AudioManager()

    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: Double = 0
    @Published private(set) var duration: Double = 0
    @Published private(set) var currentTrack: Track?

    private var tracks = Set<Track>()  // Changed from array to set
    private var currentIndex = 0
    private var player: AVPlayer?
    private var timeObserver: Any?
    
    private init() {
        configureAudioSession()
        setupRemoteCommandCenter()
        loadSavedTracks()
    }
    
    private func loadSavedTracks() {
        tracks = TrackStorageService.shared.loadTracks()
        if !tracks.isEmpty {
            prepareTrack()
        }
    }
    
    // MARK: - Public API for ViewModel
    func load(tracks newTracks: [Track]) {
        guard !newTracks.isEmpty else { return }
        let uniqueTracks = Set(newTracks)
        let oldCount = self.tracks.count
        self.tracks.formUnion(uniqueTracks)
        
        // Save tracks whenever new ones are added
        TrackStorageService.shared.saveTracks(self.tracks)
        
        // Only prepare track if we actually added new tracks
        if oldCount == 0 && !self.tracks.isEmpty {
            prepareTrack()
        }
    }

    func play() {
        player?.play()
        isPlaying = true
        updateNowPlayingInfo()
    }

    func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlayingInfo()
    }
    
    func playTrack(at index: Int) {
        let tracksArray = getTracks()
        guard index >= 0 && index < tracksArray.count else { return }
        currentIndex = index
        prepareTrack()
        play()
    }

    func nextTrack() {
        let tracksArray = getTracks()
        guard currentIndex + 1 < tracksArray.count else { return }
        currentIndex += 1
        prepareTrack()
        play()
    }

    func previousTrack() {
        guard currentIndex - 1 >= 0 else { return }
        currentIndex -= 1
        prepareTrack()
        play()
    }
    
    func getTracks() -> [Track] {
        Array(tracks).sorted { $0.title < $1.title }
    }

    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
    }

    // MARK: - Private Helpers
    private func prepareTrack() {
        let tracksArray = getTracks()
        guard currentIndex < tracksArray.count else { return }
        let track = tracksArray[currentIndex]
        currentTrack = track
        let item = AVPlayerItem(url: track.url)
        
        // Load asset metadata
        let asset = item.asset
        asset.loadValuesAsynchronously(forKeys: ["duration"]) { [weak self] in
            DispatchQueue.main.async {
                if asset.statusOfValue(forKey: "duration", error: nil) == .loaded {
                    self?.duration = asset.duration.seconds
                }
            }
        }
        
        // Remove existing observer
        if let obs = timeObserver {
            player?.removeTimeObserver(obs)
            timeObserver = nil
        }
        
        // Create new player and observe status
        player = AVPlayer(playerItem: item)
        observePlaybackTime()
        observePlayerItem(item)
        updateNowPlayingInfo(clearPlaybackRate: true)
    }
    
    private func observePlayerItem(_ item: AVPlayerItem) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: item
        )
    }
    
    @objc private func playerItemDidReachEnd() {
        nextTrack()
    }

    private func observePlaybackTime() {
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            self.updateNowPlayingInfo()
        }
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }

    private func setupRemoteCommandCenter() {
        let commands = MPRemoteCommandCenter.shared()

        commands.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }
        commands.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        commands.nextTrackCommand.addTarget { [weak self] _ in
            self?.nextTrack()
            return .success
        }
        commands.previousTrackCommand.addTarget { [weak self] _ in
            self?.previousTrack()
            return .success
        }
    }

    private func updateNowPlayingInfo(clearPlaybackRate: Bool = false) {
        var info: [String: Any] = [:]
        info[MPMediaItemPropertyTitle] = currentTrack?.title
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPMediaItemPropertyPlaybackDuration] = duration
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying && !clearPlaybackRate ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
