import Foundation

/// Raw values match the `topics` tags used in `Data/quotes.json` — keep them in sync.
enum Topic: String, CaseIterable, Identifiable, Codable {
    case all
    case motivation, wisdom, life, love, success, perseverance, creativity
    case courage, gratitude, simplicity, change, friendship, mindfulness, happiness

    var id: String { rawValue }

    var displayName: String {
        self == .all ? "All Topics" : rawValue.capitalized
    }
}
