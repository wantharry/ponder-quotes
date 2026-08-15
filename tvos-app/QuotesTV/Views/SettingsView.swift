import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
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

                Section("Display") {
                    Toggle("Show clock", isOn: $settings.showClock)
                }

                Section {
                    Toggle("Background music", isOn: $settings.musicEnabled)
                } header: {
                    Text("Music")
                } footer: {
                    Text("Music by Kevin MacLeod (incompetech.com), licensed under Creative Commons: By Attribution 4.0")
                }

                Section("Credits") {
                    Text("Some quotes adapted from Wikiquote contributors, licensed under Creative Commons: By Attribution-ShareAlike 4.0 (creativecommons.org/licenses/by-sa/4.0)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
