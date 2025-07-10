//
//  TrackStorageServiceTests.swift
//  PumpifyTests
//
//  Created by Aleksandre Shalikashvili on 11.07.25.
//

import XCTest
@testable import Pumpify

final class TrackStorageServiceTests: XCTestCase {
    
    var storageService: TrackStorageService!
    var testUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        
        // Create a test UserDefaults suite to avoid interfering with app data
        testUserDefaults = UserDefaults(suiteName: "TestSuite")!
        
        // Clear any existing test data
        testUserDefaults.removePersistentDomain(forName: "TestSuite")
        
        // Note: We would need to modify TrackStorageService to accept a UserDefaults instance
        // For now, we'll test the shared instance but be careful about cleanup
        storageService = TrackStorageService.shared
    }
    
    override func tearDown() {
        // Clean up test data
        testUserDefaults.removeObject(forKey: "saved_tracks")
        testUserDefaults = nil
        storageService = nil
        super.tearDown()
    }
    
    // MARK: - Test Save and Load Tracks
    
    func testSaveAndLoadEmptyTracks() {
        // Given
        let emptyTracks: Set<Track> = []
        
        // When
        storageService.saveTracks(emptyTracks)
        let loadedTracks = storageService.loadTracks()
        
        // Then
        XCTAssertTrue(loadedTracks.isEmpty, "Loading empty tracks should return empty set")
    }
    
    func testSaveAndLoadSingleTrack() throws {
        // Given
        let testURL = try createTestAudioFile(named: "test_audio.mp3")
        let track = Track(url: testURL)
        let tracks: Set<Track> = [track]
        
        // When
        storageService.saveTracks(tracks)
        let loadedTracks = storageService.loadTracks()
        
        // Then
        XCTAssertEqual(loadedTracks.count, 1, "Should load exactly one track")
        
        if let loadedTrack = loadedTracks.first {
            XCTAssertEqual(loadedTrack.title, track.title, "Track titles should match")
            XCTAssertEqual(loadedTrack.url.lastPathComponent, track.url.lastPathComponent, "URLs should have same filename")
        }
        
        // Cleanup
        try? FileManager.default.removeItem(at: testURL)
    }
    
    func testSaveAndLoadMultipleTracks() throws {
        // Given
        let testURL1 = try createTestAudioFile(named: "test_audio_1.mp3")
        let testURL2 = try createTestAudioFile(named: "test_audio_2.mp3")
        
        let track1 = Track(url: testURL1)
        let track2 = Track(url: testURL2)
        let tracks: Set<Track> = [track1, track2]
        
        // When
        storageService.saveTracks(tracks)
        let loadedTracks = storageService.loadTracks()
        
        // Then
        XCTAssertEqual(loadedTracks.count, 2, "Should load exactly two tracks")
        
        let loadedTitles = Set(loadedTracks.map { $0.title })
        let originalTitles = Set(tracks.map { $0.title })
        XCTAssertEqual(loadedTitles, originalTitles, "Track titles should match")
        
        // Cleanup
        try? FileManager.default.removeItem(at: testURL1)
        try? FileManager.default.removeItem(at: testURL2)
    }
    
    func testOverwriteExistingTracks() throws {
        // Given
        let testURL1 = try createTestAudioFile(named: "test_audio_1.mp3")
        let testURL2 = try createTestAudioFile(named: "test_audio_2.mp3")
        
        let track1 = Track(url: testURL1)
        let track2 = Track(url: testURL2)
        
        let firstTracks: Set<Track> = [track1]
        let secondTracks: Set<Track> = [track2]
        
        // When
        storageService.saveTracks(firstTracks)
        let firstLoadedTracks = storageService.loadTracks()
        
        storageService.saveTracks(secondTracks)
        let secondLoadedTracks = storageService.loadTracks()
        
        // Then
        XCTAssertEqual(firstLoadedTracks.count, 1, "First save should have one track")
        XCTAssertEqual(secondLoadedTracks.count, 1, "Second save should overwrite and have one track")
        
        if let loadedTrack = secondLoadedTracks.first {
            XCTAssertEqual(loadedTrack.title, track2.title, "Should have the second track's title")
        }
        
        // Cleanup
        try? FileManager.default.removeItem(at: testURL1)
        try? FileManager.default.removeItem(at: testURL2)
    }
    
    // MARK: - Test Load When No Data Exists
    
    func testLoadTracksWhenNoDataExists() {
        // Given - Clean UserDefaults
        UserDefaults.standard.removeObject(forKey: "saved_tracks")
        
        // When
        let loadedTracks = storageService.loadTracks()
        
        // Then
        XCTAssertTrue(loadedTracks.isEmpty, "Should return empty set when no data exists")
    }
    
    // MARK: - Test Corrupted Data Handling
    
    func testLoadTracksWithCorruptedData() {
        // Given - Corrupted data in UserDefaults
        let corruptedData = ["not_a_valid_bookmark_data"]
        UserDefaults.standard.set(corruptedData, forKey: "saved_tracks")
        
        // When
        let loadedTracks = storageService.loadTracks()
        
        // Then
        XCTAssertTrue(loadedTracks.isEmpty, "Should handle corrupted data gracefully")
        
        // Cleanup
        UserDefaults.standard.removeObject(forKey: "saved_tracks")
    }
    
    // MARK: - Performance Tests
    
    func testSaveTracksPerformance() throws {
        // Given
        var tracks: Set<Track> = []
        for i in 1...100 {
            let testURL = try createTestAudioFile(named: "test_audio_\(i).mp3")
            tracks.insert(Track(url: testURL))
        }
        
        // When & Then
        measure {
            storageService.saveTracks(tracks)
        }
        
        // Cleanup
        for track in tracks {
            try? FileManager.default.removeItem(at: track.url)
        }
    }
    
    func testLoadTracksPerformance() throws {
        // Given - Pre-populate with many tracks
        var tracks: Set<Track> = []
        for i in 1...100 {
            let testURL = try createTestAudioFile(named: "test_audio_\(i).mp3")
            tracks.insert(Track(url: testURL))
        }
        storageService.saveTracks(tracks)
        
        // When & Then
        measure {
            _ = storageService.loadTracks()
        }
        
        // Cleanup
        for track in tracks {
            try? FileManager.default.removeItem(at: track.url)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestAudioFile(named fileName: String) throws -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        // Create a dummy file
        let dummyData = "dummy audio data".data(using: .utf8)!
        try dummyData.write(to: fileURL)
        
        return fileURL
    }
}
