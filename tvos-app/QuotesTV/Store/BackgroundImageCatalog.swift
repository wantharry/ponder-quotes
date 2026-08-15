import Foundation

/// Maps each topic to the bundled background image asset names for that mood,
/// plus a real-photography "universe" pool (NASA imagery, public domain) that
/// can override the generated topic art when enabled in Settings.
enum BackgroundImageCatalog {
    private static let imagesByTopic: [String: [String]] = [
        "motivation": ["bg-motivation-1", "bg-motivation-2", "bg-motivation-3"],
        "wisdom": ["bg-wisdom-1", "bg-wisdom-2", "bg-wisdom-3"],
        "life": ["bg-life-1", "bg-life-2", "bg-life-3"],
        "love": ["bg-love-1", "bg-love-2", "bg-love-3"],
        "success": ["bg-success-1", "bg-success-2", "bg-success-3"],
        "perseverance": ["bg-perseverance-1", "bg-perseverance-2", "bg-perseverance-3"],
        "creativity": ["bg-creativity-1", "bg-creativity-2", "bg-creativity-3"],
        "courage": ["bg-courage-1", "bg-courage-2", "bg-courage-3"],
        "gratitude": ["bg-gratitude-1", "bg-gratitude-2", "bg-gratitude-3"],
        "simplicity": ["bg-simplicity-1", "bg-simplicity-2", "bg-simplicity-3"],
        "change": ["bg-change-1", "bg-change-2", "bg-change-3"],
        "friendship": ["bg-friendship-1", "bg-friendship-2", "bg-friendship-3"],
        "mindfulness": ["bg-mindfulness-1", "bg-mindfulness-2", "bg-mindfulness-3"],
        "happiness": ["bg-happiness-1", "bg-happiness-2", "bg-happiness-3"]
    ]

    private static let fallback = ["bg-general-1", "bg-general-2", "bg-general-3"]

    private static let universePool = (1...14).map { "universe-\($0)" }

    static func imageName(for quote: Quote?, useUniverseBackgrounds: Bool = false) -> String? {
        if useUniverseBackgrounds {
            return universePool.randomElement()
        }
        let topic = quote?.topics.first ?? ""
        let pool = imagesByTopic[topic] ?? fallback
        return pool.randomElement()
    }
}
