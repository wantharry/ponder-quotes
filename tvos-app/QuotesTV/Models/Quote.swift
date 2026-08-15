import Foundation

struct Quote: Identifiable, Codable, Hashable {
    let id: String
    let text: String
    let author: String
    let topics: [String]
}
