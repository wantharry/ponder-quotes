import SwiftUI

struct DisplayView: View {
    @ObservedObject var store: QuoteStore

    var body: some View {
        ZStack {
            background

            LinearGradient(
                colors: [.black.opacity(0.15), .black.opacity(0.55)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 28) {
                Spacer()
                if let quote = store.currentQuote {
                    Text("\u{201C}\(quote.text)\u{201D}")
                        .font(.system(size: 54, weight: .medium, design: .serif))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .shadow(radius: 14)
                        .padding(.horizontal, 160)
                        .id(quote.id)
                        .transition(.opacity)

                    Text("— \(quote.author)")
                        .font(.system(size: 26, weight: .regular, design: .serif))
                        .foregroundStyle(.white.opacity(0.85))
                        .id(quote.id + "-author")
                        .transition(.opacity)
                }
                Spacer()
                Spacer()
            }
            .animation(.easeInOut(duration: 1.2), value: store.currentQuote?.id)
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var background: some View {
        if let imageName = store.currentImageName, let uiImage = UIImage(named: imageName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .id(imageName)
                .transition(.opacity)
                .animation(.easeInOut(duration: 2.0), value: store.currentImageName)
        } else {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.12), Color(red: 0.15, green: 0.1, blue: 0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
