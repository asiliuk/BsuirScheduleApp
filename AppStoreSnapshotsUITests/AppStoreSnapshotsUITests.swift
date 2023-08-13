import XCTest
import BsuirCore
import Dependencies

@MainActor
final class AppStoreSnapshotsUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func testAppStoreSnapshots() async throws {
        let app = XCUIApplication()

        // Pretent we're running for previews to use `previewValue` dependencies
        // could not find other way to reliably override dependences for UI tests
        app.launchEnvironment["SWIFT_DEPENDENCIES_CONTEXT"] = "preview"
        app.launch()

        // Snapshot pinned
        app.tabBars.firstMatch.buttons.element(boundBy: 0).tap()
        takeScreenshot(named: "Pinned")

        // Snapshot pinned in dark mode
        XCUIDevice.shared.appearance = .dark
        try await Task.sleep(for: .seconds(1))
        takeScreenshot(named: "Pinned-Dark")
        XCUIDevice.shared.appearance = .light
        try await Task.sleep(for: .seconds(1))

        // Snapshot groups
        app.tabBars.firstMatch.buttons.element(boundBy: 1).tap()
        try await Task.sleep(for: .seconds(1))
        takeScreenshot(named: "Groups")

        // Snapshot lecturers
        app.tabBars.firstMatch.buttons.element(boundBy: 2).tap()
        try await Task.sleep(for: .seconds(1))
        takeScreenshot(named: "Lecturers")

        // Snapshot settings
        app.tabBars.firstMatch.buttons.element(boundBy: 3).tap()
        takeScreenshot(named: "Settings")
    }
}

// MARK: - Helpers

private extension AppStoreSnapshotsUITests {
    func takeScreenshot(named name: String) {
        // Take the screenshot
        let fullScreenshot = XCUIScreen.main.screenshot()

        // Create a new attachment to save our screenshot
        // and give it a name consisting of the "named"
        // parameter and the device name, so we can find
        // it later.
        let screenshotAttachment = XCTAttachment(
            uniformTypeIdentifier: "public.png",
            name: "Screenshot-\(UIDevice.current.name)-\(name).png",
            payload: fullScreenshot.pngRepresentation,
            userInfo: nil
        )

        // Usually Xcode will delete attachments after
        // the test has run; we don't want that!
        screenshotAttachment.lifetime = .keepAlways

        // Add the attachment to the test log,
        // so we can retrieve it later
        add(screenshotAttachment)
    }
}
