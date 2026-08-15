import SwiftUI

struct DisplayView: View {
    @ObservedObject var store: QuoteStore
    @EnvironmentObject var settings: AppSettings

    @State private var isZoomedIn = false

    var body: some View {
        ZStack {
            background
                .scaleEffect(isZoomedIn ? 1.08 : 1.0)
                .animation(.easeInOut(duration: 14).repeatForever(autoreverses: true), value: isZoomedIn)
                .onAppear { isZoomedIn = true }

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
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.97)),
                            removal: .opacity
                        ))
                        .animation(.easeOut(duration: 1.6), value: store.currentQuote?.id)

                    Text("— \(quote.author)")
                        .font(.system(size: 26, weight: .regular, design: .serif))
                        .foregroundStyle(.white.opacity(0.85))
                        .id(quote.id + "-author")
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity
                        ))
                        .animation(.easeOut(duration: 1.6).delay(0.25), value: store.currentQuote?.id)
                }
                Spacer()
                Spacer()
            }

            if settings.showClock {
                clockOverlay
            }
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
                .animation(.easeInOut(duration: 2.5), value: store.currentImageName)
        } else {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.12), Color(red: 0.15, green: 0.1, blue: 0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var clockOverlay: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            VStack(alignment: .trailing, spacing: 2) {
                Text(context.date, format: .dateTime.hour().minute())
                    .font(.system(size: 34, weight: .light, design: .serif))
                Text(context.date, format: .dateTime.weekday(.wide).month(.wide).day())
                    .font(.system(size: 18, weight: .light, design: .serif))
            }
            .foregroundStyle(.white.opacity(0.8))
            .shadow(radius: 8)
            .padding(.trailing, 64)
            .padding(.bottom, 48)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.6), value: context.date)
        }
    }
}
