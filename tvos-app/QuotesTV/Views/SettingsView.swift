import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @ObservedObject var store: QuoteStore
    @Environment(\.dismiss) private var dismiss

    private var currentTrackLabel: String {
        if settings.selectedTrackID == AudioPlayerService.shuffleID {
            return "Shuffle"
        }
        return AudioPlayerService.availableTracks
            .first(where: { $0.id == settings.selectedTrackID })?.displayName ?? "Shuffle"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink("Quote History") {
                        HistoryView(store: store)
                    }
                }

                Section("Playback") {
                    NavigationLink {
                        SettingsOptionList(
                            title: "Topic",
                            options: Topic.allCases.map { ($0, $0.displayName) },
                            selection: $settings.topic
                        )
                    } label: {
                        SettingsValueRow(title: "Topic", value: settings.topic.displayName)
                    }

                    NavigationLink {
                        SettingsOptionList(
                            title: "Field",
                            options: AuthorField.allCases.map { ($0, $0.displayName) },
                            selection: $settings.authorField
                        )
                    } label: {
                        SettingsValueRow(title: "Field", value: settings.authorField.displayName)
                    }

                    NavigationLink {
                        SettingsOptionList(
                            title: "Authors",
                            options: AuthorTier.allCases.map { ($0, $0.label) },
                            selection: $settings.authorTier
                        )
                    } label: {
                        SettingsValueRow(title: "Authors", value: settings.authorTier.label)
                    }

                    NavigationLink {
                        SettingsOptionList(
                            title: "Change quote every",
                            options: RotationFrequency.allCases.map { ($0, $0.label) },
                            selection: $settings.frequency
                        )
                    } label: {
                        SettingsValueRow(title: "Change quote every", value: settings.frequency.label)
                    }
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

                    NavigationLink {
                        SettingsOptionList(
                            title: "Playlist",
                            options: AudioPlayerService.playlists.map { ($0.id, $0.displayName) },
                            selection: $settings.selectedPlaylistID
                        )
                    } label: {
                        SettingsValueRow(
                            title: "Playlist",
                            value: AudioPlayerService.playlist(id: settings.selectedPlaylistID).displayName
                        )
                    }

                    NavigationLink {
                        SettingsOptionList(
                            title: "Track",
                            options: [(AudioPlayerService.shuffleID, "Shuffle")]
                                + AudioPlayerService.tracks(in: AudioPlayerService.playlist(id: settings.selectedPlaylistID))
                                    .map { ($0.id, $0.displayName) },
                            selection: $settings.selectedTrackID
                        )
                    } label: {
                        SettingsValueRow(title: "Track", value: currentTrackLabel)
                    }
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

/// A settings row showing the current value of a setting, tapped to drill into `SettingsOptionList`.
private struct SettingsValueRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

/// A single-selection list, pushed from a `SettingsValueRow`. Shows a checkmark on the
/// selected option and pops back to Settings as soon as a new one is chosen.
private struct SettingsOptionList<Value: Hashable>: View {
    let title: String
    let options: [(value: Value, label: String)]
    @Binding var selection: Value
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(options, id: \.value) { option in
                Button {
                    selection = option.value
                    dismiss()
                } label: {
                    HStack {
                        Text(option.label)
                        Spacer()
                        if option.value == selection {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                }
            }
        }
        .navigationTitle(title)
    }
}
