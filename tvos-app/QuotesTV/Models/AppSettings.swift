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
    @Published var musicEnabled: Bool {
        didSet { UserDefaults.standard.set(musicEnabled, forKey: Keys.music) }
    }
    @Published var showClock: Bool {
        didSet { UserDefaults.standard.set(showClock, forKey: Keys.clock) }
    }

    private enum Keys {
        static let topic = "quotestv.topic"
        static let frequency = "quotestv.frequency"
        static let music = "quotestv.musicEnabled"
        static let clock = "quotestv.showClock"
    }

    init() {
        let defaults = UserDefaults.standard
        topic = Topic(rawValue: defaults.string(forKey: Keys.topic) ?? "") ?? .all
        let storedFrequency = defaults.object(forKey: Keys.frequency) as? Double
        frequency = RotationFrequency(rawValue: storedFrequency ?? RotationFrequency.medium.rawValue) ?? .medium
        musicEnabled = defaults.object(forKey: Keys.music) as? Bool ?? true
        showClock = defaults.object(forKey: Keys.clock) as? Bool ?? true
    }
}
