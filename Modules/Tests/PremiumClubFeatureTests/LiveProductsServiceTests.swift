import XCTest
@testable import PremiumClubFeature

// TODO: Write tests
final class LiveProductsServiceTests: XCTestCase {
    var sut: LiveProductsService!

    override func setUp() {
        sut = LiveProductsService()
    }

    override func tearDown() {
        sut = nil
    }
}
