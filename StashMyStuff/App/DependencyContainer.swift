import Observation
import SwiftData
import SwiftUI

@Observable
final class DependencyContainer {
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                // Models will be added here in Phase 1
            ])

            // Note: CloudKit sync disabled - requires paid Apple Developer account
            // To enable later: cloudKitDatabase: .private("iCloud.com.stashmystuff.app")
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )

            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    // MARK: - Services

    // Services will be added here as the app develops
}

extension EnvironmentValues {
    @Entry
    var dependencyContainer = DependencyContainer()
}

extension View {
    func environment(_ container: DependencyContainer) -> some View {
        self.environment(\.dependencyContainer, container)
    }
}
