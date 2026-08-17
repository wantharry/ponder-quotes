import Foundation

/// Raw values match the `field` tag used in `Data/quotes.json` — keep them in sync.
enum AuthorField: String, CaseIterable, Identifiable, Codable {
    case all
    case philosophy = "Philosophy"
    case science = "Science"
    case literature = "Literature & Poetry"
    case politics = "Politics & Leadership"
    case spirituality = "Spirituality & Religion"
    case business = "Business & Entrepreneurship"
    case psychology = "Psychology & Self-Help"
    case art = "Art & Music"
    case sports = "Sports"
    case activism = "Activism & Civil Rights"
    case film = "Film & Entertainment"

    var id: String { rawValue }

    var displayName: String {
        self == .all ? "All Fields" : rawValue
    }
}
