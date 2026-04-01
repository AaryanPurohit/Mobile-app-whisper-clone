import SwiftUI

enum AppState { case idle, recording, processing }

struct ContentView: View {
    @StateObject private var recorder = AudioRecorder.shared
    @StateObject private var prefs    = PreferencesManager.shared
    @State private var appState: AppState = .idle
    @State private var showSettings = false
    @State private var showCopied   = false
    @State private var pulse        = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 48) {
                Spacer()

                // Pulsing glow ring when recording
                ZStack {
                    if appState == .recording {
                        Circle()
                            .stroke(Color.red.opacity(0.25), lineWidth: 1.5)
                            .frame(width: 150, height: 150)
                            .scaleEffect(pulse ? 1.35 : 1.0)
                            .opacity(pulse ? 0 : 0.8)
                            .animation(.easeOut(duration: 1.1).repeatForever(autoreverses: false), value: pulse)
                    }

                    // Main button
                    Button(action: handleTap) {
                        ZStack {
                            Circle()
                                .fill(buttonColor)
                                .frame(width: 110, height: 110)
                                .shadow(color: glowColor, radius: appState == .recording ? 30 : 8)

                            Image(systemName: buttonIcon)
                                .font(.system(size: 44, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .disabled(appState == .processing)
                }

                // Status label
                Text(statusLabel)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.55))
                    .animation(.easeInOut(duration: 0.2), value: appState)

                // Copied confirmation
                if showCopied {
                    Label("Copied to clipboard", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.green)
                        .transition(.opacity.combined(with: .scale))
                }

                Spacer()
            }
        }
        .overlay(alignment: .topTrailing) {
            Button { showSettings = true } label: {
                Image(systemName: "gear")
                    .font(.system(size: 22))
                    .foregroundColor(.white.opacity(0.35))
                    .padding(20)
            }
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .onAppear {
            if prefs.apiKey.isEmpty { showSettings = true }
        }
        .onChange(of: appState) { newState in
            if newState == .recording {
                pulse = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { pulse = true }
            } else {
                pulse = false
            }
        }
    }

    // MARK: - Helpers

    private var statusLabel: String {
        switch appState {
        case .idle:       return "Tap to dictate"
        case .recording:  return "Listening…"
        case .processing: return "Transcribing…"
        }
    }

    private var buttonColor: Color {
        switch appState {
        case .idle:       return Color.white.opacity(0.10)
        case .recording:  return Color.red.opacity(0.85)
        case .processing: return Color.blue.opacity(0.55)
        }
    }

    private var glowColor: Color {
        switch appState {
        case .idle:       return .clear
        case .recording:  return .red.opacity(0.45)
        case .processing: return .blue.opacity(0.35)
        }
    }

    private var buttonIcon: String {
        switch appState {
        case .idle:       return "mic"
        case .recording:  return "stop.fill"
        case .processing: return "waveform"
        }
    }

    // MARK: - Actions

    private func handleTap() {
        switch appState {
        case .idle:
            appState = .recording
            recorder.startRecording()

        case .recording:
            appState = .processing
            recorder.stopRecording { url in
                guard let url else { appState = .idle; return }
                Task {
                    do {
                        let text = try await TranscriptionService.shared.transcribe(
                            audioURL: url, apiKey: prefs.apiKey
                        )
                        await MainActor.run {
                            UIPasteboard.general.string = text
                            withAnimation { showCopied = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation { showCopied = false }
                            }
                            appState = .idle
                        }
                    } catch {
                        await MainActor.run { appState = .idle }
                    }
                }
            }

        case .processing:
            break
        }
    }
}
