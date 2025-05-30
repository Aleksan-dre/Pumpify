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

    private var tracks: [Track] = []
    private var currentIndex = 0
    private var player: AVPlayer?
    private var timeObserver: Any?

    private init() {
        configureAudioSession()
        setupRemoteCommandCenter()
    }

    // MARK: - Public API for ViewModel
    func load(tracks: [Track]) {
        guard !tracks.isEmpty else { return }
        self.tracks.append(contentsOf: tracks)
        prepareTrack()
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
        guard index >= 0 && index < tracks.count else { return }
        currentIndex = index
        prepareTrack()
        play()
    }

    func nextTrack() {
        guard currentIndex + 1 < tracks.count else { return }
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
        tracks
    }

    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
    }

    // MARK: - Private Helpers
    private func prepareTrack() {
        let track = tracks[currentIndex]
        currentTrack = track
        let item = AVPlayerItem(url: track.url)
        if let obs = timeObserver {
            player?.removeTimeObserver(obs)
            timeObserver = nil
        }
        player = AVPlayer(playerItem: item)
        duration = item.asset.duration.seconds
        observePlaybackTime()
        updateNowPlayingInfo(clearPlaybackRate: true)
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
