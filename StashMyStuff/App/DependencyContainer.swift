import SwiftData
import SwiftUI

/// Container for app-wide dependencies and services.
/// Used to set up SwiftData ModelContainer and will hold services in later phases.
enum DependencyContainer {
    /// Creates the SwiftData ModelContainer for the app.
    /// - Parameter inMemory: If true, stores data in memory only (for testing/previews)
    /// - Returns: Configured ModelContainer
    @MainActor
    static func makeModelContainer(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([
            // Models will be added here in Phase 1
        ])

        // Note: CloudKit sync disabled - requires paid Apple Developer account
        // To enable later: cloudKitDatabase: .private("iCloud.com.stashmystuff.app")
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
