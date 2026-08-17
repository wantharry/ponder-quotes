import Foundation

/// Filters the quote deck down to the N most globally recognizable authors,
/// ranked in `Quote.authorRank` (1 = most famous).
enum AuthorTier: Int, CaseIterable, Identifiable, Codable {
    case top10 = 10
    case top50 = 50
    case top100 = 100
    case all = 200

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .top10: return "Top 10"
        case .top50: return "Top 50"
        case .top100: return "Top 100"
        case .all: return "All 200"
        }
    }
}
