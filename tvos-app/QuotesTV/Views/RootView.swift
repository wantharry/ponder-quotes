import SwiftUI
import UIKit

struct RootView: View {
    @EnvironmentObject var settings: AppSettings
    @StateObject private var store: QuoteStore
    @StateObject private var audio = AudioPlayerService()
    @State private var showSettings = false

    init(settings: AppSettings) {
        _store = StateObject(wrappedValue: QuoteStore(settings: settings))
    }

    var body: some View {
        // DisplayView must NOT be wrapped in a Button. Two reasons, both
        // found the hard way: a Button's label sits inside tvOS's own focus
        // rendering container, which (a) clips/overrides child-level
        // scaleEffect/offset transforms — silently killing the Ken Burns
        // background animation — and (b) shows a system focus-glow/blur
        // material over the whole label whenever it has focus, which for a
        // screen-filling button washes out the entire display. A plain
        // `.focusable` view with `.onTapGesture` gets the Select-click
        // without either side effect.
        DisplayView(store: store)
            .focusable(true)
            .onTapGesture { showSettings = true }
        // Play/Pause is a nice shortcut when the remote has one and no audio
        // is claiming it, but Select-click (above) is the reliable path —
        // every remote has it, and it can't be captured by the system for
        // audio transport the way Play/Pause sometimes is once background
        // music is actually playing.
        .onPlayPauseCommand { showSettings = true }
        .sheet(isPresented: $showSettings) {
            SettingsView(store: store)
        }
        .onAppear {
            // Quotes are the show here — don't let tvOS's screensaver
            // (or auto-sleep) interrupt it just because the remote sits idle.
            UIApplication.shared.isIdleTimerDisabled = true
            audio.syncWithSettings(settings)
        }
        .onChange(of: settings.musicEnabled) { _, enabled in
            audio.setEnabled(enabled, settings: settings)
        }
        .onChange(of: settings.selectedTrackID) { _, _ in
            audio.applySelection(settings)
        }
        .onChange(of: settings.selectedPlaylistID) { _, _ in
            audio.applySelection(settings)
        }
    }
}
