import SwiftUI
import TipKit

@main
struct MyApp: App {
    init() {
        try? Tips.configure()
        try? Tips.resetDatastore()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
