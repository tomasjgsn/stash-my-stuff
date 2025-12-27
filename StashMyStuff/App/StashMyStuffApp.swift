import SwiftData
import SwiftUI

@main
struct StashMyStuffApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // ModelContainer for SwiftData persistence
        // Creates database for StashItem and Tag models
        .modelContainer(for: [StashItem.self, Tag.self])

        #if os(macOS)
            Settings {
                SettingsView()
            }
        #endif
    }
}

#if os(macOS)
    struct SettingsView: View {
        var body: some View {
            Text("Settings")
                .frame(width: 400, height: 300)
        }
    }
#endif
