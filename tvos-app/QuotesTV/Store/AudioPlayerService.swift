import Foundation
import Combine
import AVFoundation

/// Loops a bundled ambient track for the background music.
///
/// Picks one of the bundled `ambient-N.mp3` tracks at random each time
/// playback starts, so relaunching the app doesn't always favor the same
/// one. With none present this is a silent no-op rather than a crash, so
/// the app runs fine before any tracks are added.
final class AudioPlayerService: ObservableObject {
    private var player: AVAudioPlayer?
    private let trackNames = ["ambient-1", "ambient-2", "ambient-3"]

    func syncWithSettings(_ settings: AppSettings) {
        setEnabled(settings.musicEnabled)
    }

    func setEnabled(_ enabled: Bool) {
        guard enabled else {
            player?.stop()
            return
        }
        if let player {
            player.play()
            return
        }
        guard let track = trackNames.compactMap({ Bundle.main.url(forResource: $0, withExtension: "mp3") }).shuffled().first else {
            return
        }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, options: [.mixWithOthers])
            try session.setActive(true)
            let newPlayer = try AVAudioPlayer(contentsOf: track)
            newPlayer.numberOfLoops = -1
            newPlayer.volume = 0.5
            newPlayer.prepareToPlay()
            newPlayer.play()
            player = newPlayer
        } catch {
            player = nil
        }
    }
}
