import Foundation
import Combine

struct HistoryEntry: Identifiable {
    let id = UUID()
    let quote: Quote
    let shownAt: Date
}

/// Loads the bundled quote deck, filters it by the selected topic, and rotates
/// through it on a timer using a shuffle-bag (so a quote can't repeat until
/// every other quote in the current filter has been shown).
final class QuoteStore: ObservableObject {
    @Published private(set) var currentQuote: Quote?
    @Published private(set) var currentImageName: String?
    @Published private(set) var history: [HistoryEntry] = []

    private static let historyLimit = 50

    private var allQuotes: [Quote] = []
    private var bag: [Quote] = []
    private var timer: Timer?
    private let settings: AppSettings
    private var cancellables = Set<AnyCancellable>()

    init(settings: AppSettings) {
        self.settings = settings
        loadQuotes()

        settings.$topic
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in self?.restart() }
            .store(in: &cancellables)

        settings.$frequency
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in self?.scheduleTimer() }
            .store(in: &cancellables)

        restart()
    }

    private func loadQuotes() {
        guard let url = Bundle.main.url(forResource: "quotes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Quote].self, from: data) else {
            assertionFailure("quotes.json missing or malformed — check it's added to the app target.")
            allQuotes = []
            return
        }
        allQuotes = decoded
    }

    private func filteredQuotes() -> [Quote] {
        guard settings.topic != .all else { return allQuotes }
        return allQuotes.filter { $0.topics.contains(settings.topic.rawValue) }
    }

    private func restart() {
        bag = filteredQuotes().shuffled()
        advance()
        scheduleTimer()
    }

    private func advance() {
        if bag.isEmpty {
            bag = filteredQuotes().shuffled()
        }
        currentQuote = bag.popLast()
        currentImageName = BackgroundImageCatalog.imageName(for: currentQuote)

        if let quote = currentQuote {
            history.insert(HistoryEntry(quote: quote, shownAt: Date()), at: 0)
            if history.count > Self.historyLimit {
                history.removeLast(history.count - Self.historyLimit)
            }
        }
    }

    private func scheduleTimer() {
        timer?.invalidate()
        guard !bag.isEmpty || !filteredQuotes().isEmpty else { return }
        timer = Timer.scheduledTimer(withTimeInterval: settings.frequency.rawValue, repeats: true) { [weak self] _ in
            self?.advance()
        }
    }
}
