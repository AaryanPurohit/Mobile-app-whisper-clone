import SwiftUI

struct SettingsView: View {
    @ObservedObject private var prefs = PreferencesManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showKey = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Group {
                            if showKey {
                                TextField("sk-…", text: $prefs.apiKey)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                            } else {
                                SecureField("sk-…", text: $prefs.apiKey)
                            }
                        }
                        Button(showKey ? "Hide" : "Show") { showKey.toggle() }
                            .foregroundColor(.accentColor)
                    }
                    Text("Used for Whisper transcription. Stored locally on device.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("OpenAI API Key")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .disabled(prefs.apiKey.isEmpty)
                }
            }
        }
    }
}
