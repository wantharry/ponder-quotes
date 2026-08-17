import Foundation
import Combine

/// User-facing preferences, persisted to UserDefaults so they survive app relaunches.
final class AppSettings: ObservableObject {
    @Published var topic: Topic {
        didSet { UserDefaults.standard.set(topic.rawValue, forKey: Keys.topic) }
    }
    @Published var frequency: RotationFrequency {
        didSet { UserDefaults.standard.set(frequency.rawValue, forKey: Keys.frequency) }
    }
    @Published var authorTier: AuthorTier {
        didSet { UserDefaults.standard.set(authorTier.rawValue, forKey: Keys.authorTier) }
    }
    @Published var authorField: AuthorField {
        didSet { UserDefaults.standard.set(authorField.rawValue, forKey: Keys.authorField) }
    }
    @Published var musicEnabled: Bool {
        didSet { UserDefaults.standard.set(musicEnabled, forKey: Keys.music) }
    }
    @Published var showClock: Bool {
        didSet { UserDefaults.standard.set(showClock, forKey: Keys.clock) }
    }
    @Published var useUniverseBackgrounds: Bool {
        didSet { UserDefaults.standard.set(useUniverseBackgrounds, forKey: Keys.universe) }
    }
    /// Empty string means "shuffle" — see `AudioPlayerService.shuffleID`.
    @Published var selectedTrackID: String {
        didSet { UserDefaults.standard.set(selectedTrackID, forKey: Keys.selectedTrack) }
    }
    /// Which `MusicPlaylist` shuffle draws from — see `AudioPlayerService.playlists`.
    @Published var selectedPlaylistID: String {
        didSet { UserDefaults.standard.set(selectedPlaylistID, forKey: Keys.selectedPlaylist) }
    }

    private enum Keys {
        static let topic = "quotestv.topic"
        static let frequency = "quotestv.frequency"
        static let authorTier = "quotestv.authorTier"
        static let authorField = "quotestv.authorField"
        static let music = "quotestv.musicEnabled"
        static let clock = "quotestv.showClock"
        static let universe = "quotestv.useUniverseBackgrounds"
        static let selectedTrack = "quotestv.selectedTrackID"
        static let selectedPlaylist = "quotestv.selectedPlaylistID"
    }

    init() {
        let defaults = UserDefaults.standard
        topic = Topic(rawValue: defaults.string(forKey: Keys.topic) ?? "") ?? .all
        let storedFrequency = defaults.object(forKey: Keys.frequency) as? Double
        frequency = RotationFrequency(rawValue: storedFrequency ?? RotationFrequency.medium.rawValue) ?? .medium
        let storedAuthorTier = defaults.object(forKey: Keys.authorTier) as? Int
        authorTier = AuthorTier(rawValue: storedAuthorTier ?? AuthorTier.top50.rawValue) ?? .top50
        authorField = AuthorField(rawValue: defaults.string(forKey: Keys.authorField) ?? "") ?? .all
        musicEnabled = defaults.object(forKey: Keys.music) as? Bool ?? true
        showClock = defaults.object(forKey: Keys.clock) as? Bool ?? true
        useUniverseBackgrounds = defaults.object(forKey: Keys.universe) as? Bool ?? false
        selectedTrackID = defaults.string(forKey: Keys.selectedTrack) ?? ""
        selectedPlaylistID = defaults.string(forKey: Keys.selectedPlaylist) ?? AudioPlayerService.defaultPlaylistID
    }
}
