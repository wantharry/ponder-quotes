import SwiftUI

struct DisplayView: View {
    @ObservedObject var store: QuoteStore
    @EnvironmentObject var settings: AppSettings

    @State private var kenBurnsScale: CGFloat = 1.0
    @State private var kenBurnsOffset: CGSize = .zero

    private static let zoomedInScale: CGFloat = 1.15
    private static let panDistance: CGFloat = 70
    private static let panAngles: [Double] = [0, 45, 90, 135, 180, 225, 270, 315]

    var body: some View {
        ZStack {
            background
                .scaleEffect(kenBurnsScale)
                .offset(kenBurnsOffset)
                .onAppear { startKenBurns() }
                .onChange(of: store.currentImageName) { _, _ in startKenBurns() }

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

    /// Classic Ken Burns treatment: each image randomly zooms in or out while
    /// drifting toward a random direction, so consecutive images don't repeat
    /// the same motion. Snaps back to a fresh starting state instantly, then
    /// animates — the crossfade in `background` masks the snap.
    private func startKenBurns() {
        let zoomingIn = Bool.random()
        let angle = Self.panAngles.randomElement() ?? 0
        let radians = angle * .pi / 180
        let dx = Self.panDistance * cos(radians)
        let dy = Self.panDistance * sin(radians)
        let pannedOffset = CGSize(width: dx, height: dy)

        // The background is scaled to exactly cover the screen at 1.0, so that scale has
        // zero margin to pan within — only the zoomed-in scale has room to spare. Always
        // pair the offset with the zoomed-in end, whichever side of the animation it's on,
        // or panning at the 1.0 end exposes a gap past the image's edge.
        kenBurnsScale = zoomingIn ? 1.0 : Self.zoomedInScale
        kenBurnsOffset = zoomingIn ? .zero : pannedOffset

        withAnimation(.easeInOut(duration: 18)) {
            kenBurnsScale = zoomingIn ? Self.zoomedInScale : 1.0
            kenBurnsOffset = zoomingIn ? pannedOffset : .zero
        }
    }

    @ViewBuilder
    private var background: some View {
        if let imageName = store.currentImageName, let uiImage = UIImage(named: imageName) {
            // GeometryReader forces an exact pixel frame — `.frame(maxWidth: .infinity,
            // maxHeight: .infinity)` alone left portrait/odd-aspect source photos
            // pillarboxed instead of actually resizing to cover the screen.
            GeometryReader { geo in
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
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
