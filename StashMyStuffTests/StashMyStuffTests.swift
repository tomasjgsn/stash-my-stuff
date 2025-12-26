import Testing
@testable import StashMyStuff

@Suite("StashMyStuff Tests")
struct StashMyStuffTests {
    @Test("App initializes correctly")
    func appInitialization() async throws {
        // Placeholder test to verify test infrastructure works
        #expect(true)
    }

    @Test("Dependency container creates model container")
    @MainActor
    func dependencyContainerCreation() async throws {
        let container = DependencyContainer.makeModelContainer(inMemory: true)
        #expect(container.schema.entities.isEmpty) // No models defined yet
    }
}
