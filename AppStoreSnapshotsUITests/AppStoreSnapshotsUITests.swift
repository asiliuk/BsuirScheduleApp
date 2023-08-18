import XCTest
import BsuirCore
import Dependencies

final class AppStoreSnapshotsUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true

        app = XCUIApplication()

        // Setup snapshot
        setupSnapshot(app)

        // Pass flag to disable animations and other things not needed for tests
        app.launchArguments += ["enable-testing"]

        // Pretent we're running for previews to use `previewValue` dependencies
        // could not find other way to reliably override dependences for UI tests
        app.launchEnvironment["SWIFT_DEPENDENCIES_CONTEXT"] = "preview"
    }

    override func tearDownWithError() throws {
        XCUIDevice.shared.appearance = .light
        app.terminate()
        app = nil
    }

    func testAppStoreSnapshots() throws {
        // Start the app
        app.launch()

        // Snapshot pinned
        app.tabBars.firstMatch.buttons.element(boundBy: 0).tap()
        _ = app.staticTexts["151004"].waitForExistence(timeout: 5)
        snapshot("1_Pinned-Light")

        // Schedule accessibility snapshot is in separate test
        // snapshot("2_Schedule-Dark-XXL")

        // Snapshot groups
        app.tabBars.firstMatch.buttons.element(boundBy: 1).tap()
        _ = app.collectionViews.cells.buttons["151004"].waitForExistence(timeout: 5)
        snapshot("3_Groups")

        // Snapshot lecturers
        app.tabBars.firstMatch.buttons.element(boundBy: 2).tap()
        _ = app.collectionViews.cells.buttons["Куликов Святослав Святославович"].waitForExistence(timeout: 5)
        snapshot("4_Lecturers")

        // Snapshot settings
        app.tabBars.firstMatch.buttons.element(boundBy: 3).tap()
        snapshot("5_Settings")
    }

    func testDynamicTypeAppStoreSnapshot() {
        // Set dark mode
        XCUIDevice.shared.appearance = .dark

        // Set dynamic type to accessibility medium
        app.launchArguments += [
            "-UIPreferredContentSizeCategoryName",
            "\(UIContentSizeCategory.accessibilityMedium.rawValue)"
        ]

        // Start the app
        app.launch()

        // Open groups screen
        app.tabBars.firstMatch.buttons.element(boundBy: 1).tap()
        let groupRow = app.collectionViews.cells.buttons["010101"]
        _ = groupRow.waitForExistence(timeout: 5)

        // Open group schedule
        groupRow.tap()
        _ = app.staticTexts["151001"].waitForExistence(timeout: 5)

        // Snapshot schedule
        snapshot("2_Schedule-Dark-XXL")
    }

    func testWidgetsPreviewSnapshot() {
        // Pass flag to open widget preview UI
        app.launchArguments += ["enable-widget-preview"]

        // Set dark mode
        XCUIDevice.shared.appearance = .dark

        // Start the app
        app.launch()

        // Snapshot widgets preview
        snapshot("0_Widgets")
    }
}
