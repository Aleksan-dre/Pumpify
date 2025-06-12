import Foundation

final class TrackStorageService {
    static let shared = TrackStorageService()
    private let defaults = UserDefaults.standard
    private let storageKey = "saved_tracks"
    
    private init() {}
    
    func saveTracks(_ tracks: Set<Track>) {
        let urls = tracks.map { $0.url.bookmarkData() }
        defaults.set(urls, forKey: storageKey)
    }
    
    func loadTracks() -> Set<Track> {
        guard let savedData = defaults.array(forKey: storageKey) as? [Data] else {
            return []
        }
        
        return Set(savedData.compactMap { data -> Track? in
            guard let url = URL(bookmarkData: data) else { return nil }
            return Track(url: url)
        })
    }
}
