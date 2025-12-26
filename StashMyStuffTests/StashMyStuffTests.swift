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
    func dependencyContainerCreation() async throws {
        let container = DependencyContainer()
        #expect(container.modelContainer != nil)
    }
}
