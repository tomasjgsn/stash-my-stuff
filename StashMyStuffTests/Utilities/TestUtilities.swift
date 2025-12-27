import Foundation
import SwiftData
@testable import StashMyStuff

enum TestUtilities {
    /// Creates an in-memory model container for testing
    @MainActor
    static func createTestModelContainer() throws -> ModelContainer {
        let schema = Schema([
            StashItem.self,
            Tag.self
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
}
