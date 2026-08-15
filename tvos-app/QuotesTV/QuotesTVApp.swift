import SwiftUI

@main
struct QuotesTVApp: App {
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            RootView(settings: settings)
                .environmentObject(settings)
        }
    }
}
