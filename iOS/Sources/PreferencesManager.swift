import Foundation
import Combine

class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()

    @Published var apiKey: String {
        didSet { UserDefaults.standard.set(apiKey, forKey: "openai_api_key") }
    }

    private init() {
        self.apiKey = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    }
}
