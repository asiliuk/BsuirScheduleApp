import XCTest
import BsuirCore
import Dependencies

final class AppStoreSnapshotsUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppStoreSnapshots() throws {
        let app = XCUIApplication()

        // Setup snapshot
        setupSnapshot(app)

        // Pass flag to disable animations and other things not needed for tests
        app.launchArguments += ["enable-testing"]

        // Pretent we're running for previews to use `previewValue` dependencies
        // could not find other way to reliably override dependences for UI tests
        app.launchEnvironment["SWIFT_DEPENDENCIES_CONTEXT"] = "preview"

        // Start the app
        app.launch()

        // Snapshot pinned
        app.tabBars.firstMatch.buttons.element(boundBy: 0).tap()
        _ = app.staticTexts["151004"].waitForExistence(timeout: 5)
        snapshot("0Pinned-Light")

        // Snapshot pinned in dark mode
        XCUIDevice.shared.appearance = .dark
        snapshot("1Pinned-Dark")
        XCUIDevice.shared.appearance = .light

        // Snapshot groups
        app.tabBars.firstMatch.buttons.element(boundBy: 1).tap()
        _ = app.collectionViews.cells.buttons["151004"].waitForExistence(timeout: 5)
        snapshot("2Groups")

        // Snapshot lecturers
        app.tabBars.firstMatch.buttons.element(boundBy: 2).tap()
        _ = app.collectionViews.cells.buttons["Куликов Святослав Святославович"].waitForExistence(timeout: 5)
        snapshot("3Lecturers")

        // Snapshot settings
        app.tabBars.firstMatch.buttons.element(boundBy: 3).tap()
        snapshot("4Settings")
    }
}
