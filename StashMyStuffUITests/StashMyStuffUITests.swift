import XCTest

final class StashMyStuffUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Teardown code
    }

    @MainActor
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify the main view appears
        XCTAssertTrue(app.staticTexts["Stash My Stuff"].exists)
    }

    @MainActor
    func testHomeScreenDisplaysCorrectly() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify tagline is visible
        let tagline = app.staticTexts["Track the journey from 'want' to 'have' to 'loved it'."]
        XCTAssertTrue(tagline.exists)
    }
}
