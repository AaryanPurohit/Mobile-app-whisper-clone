import AVFoundation
import Combine

class AudioRecorder: ObservableObject {
    static let shared = AudioRecorder()

    @Published var isRecording = false
    private var recorder: AVAudioRecorder?

    private init() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.record, mode: .default, options: [])
        try? session.setActive(true)
    }

    func startRecording() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            guard granted else { return }
            DispatchQueue.main.async { self._start() }
        }
    }

    private func _start() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("wc_recording.m4a")
        let settings: [String: Any] = [
            AVFormatIDKey:            Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey:          44100,
            AVNumberOfChannelsKey:    1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        recorder = try? AVAudioRecorder(url: url, settings: settings)
        recorder?.record()
        isRecording = true
    }

    func stopRecording(completion: @escaping (URL?) -> Void) {
        guard let r = recorder, r.isRecording else { completion(nil); return }
        let url = r.url
        r.stop()
        recorder = nil
        isRecording = false
        completion(url)
    }
}
