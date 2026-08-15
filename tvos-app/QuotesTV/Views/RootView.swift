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
        DisplayView(store: store)
            // Play/Pause on the Siri Remote doesn't conflict with anything else
            // on an ambient display, so it doubles as "open settings".
            .onPlayPauseCommand { showSettings = true }
            .sheet(isPresented: $showSettings) {
                SettingsView()
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
