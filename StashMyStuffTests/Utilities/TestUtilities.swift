import Foundation
import SwiftData
@testable import StashMyStuff

enum TestUtilities {
    static func createTestModelContainer() throws -> ModelContainer {
        let schema = Schema([
            // Models will be added here in Phase 1
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        return try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
    }

    static func createTestDependencyContainer() -> DependencyContainer {
        DependencyContainer()
    }
}
