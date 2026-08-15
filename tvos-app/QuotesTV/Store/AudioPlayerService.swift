import Foundation
import Combine
import AVFoundation

struct MusicTrack: Identifiable, Hashable {
    let id: String
    let displayName: String
}

/// Loops a bundled ambient track for the background music.
///
/// Either shuffles among all bundled tracks (default) or, if the user picked
/// one in Settings, always plays that one. With no bundled files this is a
/// silent no-op rather than a crash, so the app runs fine either way.
final class AudioPlayerService: ObservableObject {
    static let shuffleID = ""

    static let availableTracks: [MusicTrack] = [
        MusicTrack(id: "ambient-1", displayName: "Soaring"),
        MusicTrack(id: "ambient-2", displayName: "Healing"),
        MusicTrack(id: "ambient-3", displayName: "Overheat"),
        MusicTrack(id: "ambient-indian-1", displayName: "Dhaka"),
        MusicTrack(id: "ambient-indian-2", displayName: "Vadodora (Chill Mix)"),
        MusicTrack(id: "ambient-indian-3", displayName: "Jalandhar"),
        MusicTrack(id: "ambient-indian-4", displayName: "Hidden Wonders"),
        MusicTrack(id: "ambient-indian-5", displayName: "Naraina"),
    ]

    private var player: AVAudioPlayer?
    private var currentTrackID: String?

    func syncWithSettings(_ settings: AppSettings) {
        applyTrackSelection(settings)
        setEnabled(settings.musicEnabled)
    }

    /// Call when the user changes which track to play — swaps immediately if
    /// music is already on, rather than waiting for the next launch.
    func applyTrackSelection(_ settings: AppSettings) {
        let wanted = settings.selectedTrackID
        guard wanted != Self.shuffleID, wanted != currentTrackID, settings.musicEnabled else { return }
        player?.stop()
        player = nil
        start(preferredID: wanted)
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
        start(preferredID: nil)
    }

    private func start(preferredID: String?) {
        let candidates: [String]
        if let preferredID, preferredID != Self.shuffleID {
            candidates = [preferredID]
        } else {
            candidates = Self.availableTracks.map(\.id).shuffled()
        }
        guard let id = candidates.first(where: { Bundle.main.url(forResource: $0, withExtension: "mp3") != nil }),
              let track = Bundle.main.url(forResource: id, withExtension: "mp3") else {
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
            currentTrackID = id
        } catch {
            player = nil
            currentTrackID = nil
        }
    }
}
