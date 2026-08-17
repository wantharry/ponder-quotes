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

        settings.$authorTier
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in self?.restart() }
            .store(in: &cancellables)

        settings.$authorField
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in self?.restart() }
            .store(in: &cancellables)

        settings.$frequency
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in self?.scheduleTimer() }
            .store(in: &cancellables)

        settings.$useUniverseBackgrounds
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in self?.refreshBackground() }
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
        var quotes = allQuotes.filter { $0.authorRank <= settings.authorTier.rawValue }
        if settings.authorField != .all {
            quotes = quotes.filter { $0.field == settings.authorField.rawValue }
        }
        if settings.topic != .all {
            quotes = quotes.filter { $0.topics.contains(settings.topic.rawValue) }
        }
        return quotes
    }

    private func restart() {
        reshuffleBag()
        advance()
        scheduleTimer()
    }

    /// Shuffles a fresh bag from the current filter, guarding against the shuffle
    /// landing the quote we just showed back at the end (about to be popped next) —
    /// so a cycle boundary or a filter change never repeats the same quote twice in a row.
    private func reshuffleBag() {
        bag = filteredQuotes().shuffled()
        if bag.count > 1, bag.last?.id == currentQuote?.id {
            bag.swapAt(bag.count - 1, Int.random(in: 0..<bag.count - 1))
        }
    }

    private func advance() {
        if bag.isEmpty {
            reshuffleBag()
        }
        currentQuote = bag.popLast()
        refreshBackground()

        if let quote = currentQuote {
            history.insert(HistoryEntry(quote: quote, shownAt: Date()), at: 0)
            if history.count > Self.historyLimit {
                history.removeLast(history.count - Self.historyLimit)
            }
        }
    }

    private func refreshBackground() {
        currentImageName = BackgroundImageCatalog.imageName(
            for: currentQuote,
            useUniverseBackgrounds: settings.useUniverseBackgrounds
        )
    }

    private func scheduleTimer() {
        timer?.invalidate()
        guard !bag.isEmpty || !filteredQuotes().isEmpty else { return }
        timer = Timer.scheduledTimer(withTimeInterval: settings.frequency.rawValue, repeats: true) { [weak self] _ in
            self?.advance()
        }
    }
}
