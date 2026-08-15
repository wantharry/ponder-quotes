import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @ObservedObject var store: QuoteStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink("Quote History") {
                        HistoryView(store: store)
                    }
                }

                Section("Topic") {
                    Picker("Topic", selection: $settings.topic) {
                        ForEach(Topic.allCases) { topic in
                            Text(topic.displayName).tag(topic)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section("Change quote every") {
                    Picker("Frequency", selection: $settings.frequency) {
                        ForEach(RotationFrequency.allCases) { frequency in
                            Text(frequency.label).tag(frequency)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section {
                    Toggle("Show clock", isOn: $settings.showClock)
                    Toggle("Universe backgrounds", isOn: $settings.useUniverseBackgrounds)
                } header: {
                    Text("Display")
                } footer: {
                    Text("Universe backgrounds replace the topic-colored art with real NASA space photography (public domain).")
                }

                Section {
                    Toggle("Background music", isOn: $settings.musicEnabled)
                    Picker("Track", selection: $settings.selectedTrackID) {
                        Text("Shuffle").tag(AudioPlayerService.shuffleID)
                        ForEach(AudioPlayerService.availableTracks) { track in
                            Text(track.displayName).tag(track.id)
                        }
                    }
                    .pickerStyle(.inline)
                } header: {
                    Text("Music")
                } footer: {
                    Text("Music by Kevin MacLeod (incompetech.com), licensed under Creative Commons: By Attribution 4.0")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
