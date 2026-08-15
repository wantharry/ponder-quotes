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
        Button {
            showSettings = true
        } label: {
            DisplayView(store: store)
        }
        .buttonStyle(.plain)
        // Play/Pause is a nice shortcut when the remote has one and no audio
        // is claiming it, but Select-click (the Button above) is the
        // reliable path — every remote has it, and it can't be captured by
        // the system for audio transport the way Play/Pause sometimes is
        // once background music is actually playing.
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
            audio.setEnabled(enabled)
        }
    }
}
