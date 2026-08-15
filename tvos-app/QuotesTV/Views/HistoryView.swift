import SwiftUI

struct HistoryView: View {
    @ObservedObject var store: QuoteStore

    var body: some View {
        Group {
            if store.history.isEmpty {
                ContentUnavailableView(
                    "No History Yet",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Quotes will show up here as they're displayed.")
                )
            } else {
                List(store.history) { entry in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\u{201C}\(entry.quote.text)\u{201D}")
                            .font(.system(.body, design: .serif))
                        HStack {
                            Text("— \(entry.quote.author)")
                                .font(.system(.subheadline, design: .serif))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(entry.shownAt, format: .dateTime.hour().minute())
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Quote History")
    }
}
