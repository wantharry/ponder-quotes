import Foundation

struct Quote: Identifiable, Codable, Hashable {
    let id: String
    let text: String
    let author: String
    /// 1 = most globally recognizable author, 200 = least. Backs the "Authors" tier filter in Settings.
    let authorRank: Int
    let topics: [String]
}
