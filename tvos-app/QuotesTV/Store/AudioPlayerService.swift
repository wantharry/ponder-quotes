import Foundation
import Combine
import AVFoundation

struct MusicTrack: Identifiable, Hashable {
    let id: String
    let displayName: String
}

struct MusicPlaylist: Identifiable, Hashable {
    let id: String
    let displayName: String
    let trackIDs: [String]
}

/// Loops a bundled ambient track for the background music.
///
/// Tracks are grouped into playlists; Shuffle picks randomly within whatever
/// playlist is selected in Settings, or the user can pin one specific track.
/// With no bundled files this is a silent no-op rather than a crash, so the
/// app runs fine either way.
final class AudioPlayerService: ObservableObject {
    static let shuffleID = ""

    private static let originalTrackIDs = ["ambient-1", "ambient-2", "ambient-3"]
    private static let indianTrackIDs = [
        "ambient-indian-1", "ambient-indian-2", "ambient-indian-3", "ambient-indian-4", "ambient-indian-5",
    ]

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

    /// Add new playlists here as more tracks come in — everything else
    /// (Settings pickers, shuffle scoping) reads from this list.
    static let playlists: [MusicPlaylist] = [
        MusicPlaylist(id: "full", displayName: "Full Mix", trackIDs: originalTrackIDs + indianTrackIDs),
        MusicPlaylist(id: "original", displayName: "Original", trackIDs: originalTrackIDs),
        MusicPlaylist(id: "indian", displayName: "Indian", trackIDs: indianTrackIDs),
    ]
    static let defaultPlaylistID = "full"

    static func playlist(id: String) -> MusicPlaylist {
        playlists.first(where: { $0.id == id }) ?? playlists[0]
    }

    static func tracks(in playlist: MusicPlaylist) -> [MusicTrack] {
        availableTracks.filter { playlist.trackIDs.contains($0.id) }
    }

    private var player: AVAudioPlayer?
    private var currentTrackID: String?

    func syncWithSettings(_ settings: AppSettings) {
        applySelection(settings)
        setEnabled(settings.musicEnabled, settings: settings)
    }

    /// Call when the user changes the playlist or the specific track — swaps
    /// immediately if music is already on, rather than waiting for a relaunch.
    func applySelection(_ settings: AppSettings) {
        guard settings.musicEnabled else { return }
        let playlist = Self.playlist(id: settings.selectedPlaylistID)
        let wanted = settings.selectedTrackID
        let stillValid = wanted == Self.shuffleID || playlist.trackIDs.contains(wanted)
        let target = stillValid ? wanted : Self.shuffleID
        guard target != currentTrackID || target == Self.shuffleID else { return }
        if target != currentTrackID {
            player?.stop()
            player = nil
            start(preferredID: target, playlist: playlist)
        }
    }

    func setEnabled(_ enabled: Bool, settings: AppSettings) {
        guard enabled else {
            player?.stop()
            return
        }
        if let player {
            player.play()
            return
        }
        let playlist = Self.playlist(id: settings.selectedPlaylistID)
        let preferred = settings.selectedTrackID
        start(preferredID: preferred.isEmpty ? nil : preferred, playlist: playlist)
    }

    private func start(preferredID: String?, playlist: MusicPlaylist) {
        let candidates: [String]
        if let preferredID, preferredID != Self.shuffleID {
            candidates = [preferredID]
        } else {
            candidates = playlist.trackIDs.shuffled()
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
