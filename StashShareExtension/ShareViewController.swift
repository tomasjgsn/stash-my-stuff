import SwiftUI
import UniformTypeIdentifiers

@main
struct StashShareExtension: App {
    var body: some Scene {
        ShareExtensionScene()
    }
}

struct ShareExtensionScene: Scene {
    var body: some Scene {
        WindowGroup {
            ShareView()
        }
    }
}

class ShareExtensionHostingController: NSObject {
    @MainActor
    static func createHostingController() -> some View {
        ShareView()
    }
}
