import Foundation

enum RotationFrequency: Double, CaseIterable, Identifiable, Codable {
    case fast = 10
    case short = 20
    case medium = 45
    case long = 90
    case slow = 180

    var id: Double { rawValue }

    var label: String {
        switch self {
        case .fast: return "10 seconds"
        case .short: return "20 seconds"
        case .medium: return "45 seconds"
        case .long: return "90 seconds"
        case .slow: return "3 minutes"
        }
    }
}
