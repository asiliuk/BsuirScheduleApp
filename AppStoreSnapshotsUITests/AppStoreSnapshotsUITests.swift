import XCTest
import BsuirCore
import Dependencies

final class AppStoreSnapshotsUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func testAppStoreSnapshots() throws {
        let app = XCUIApplication()

        // Pretent we're running for previews to use `previewValue` dependencies
        // could not find other way to reliably override dependences for UI tests
        app.launchEnvironment["XCODE_RUNNING_FOR_PREVIEWS"] = "1"
        app.launch()

        app.tabBars["Панель вкладок"].buttons["Настройки"].tap()
        app.collectionViews/*@START_MENU_TOKEN@*/.buttons["О приложении"]/*[[".cells.buttons[\"О приложении\"]",".buttons[\"О приложении\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

        takeScreenshot(named: "About")
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
