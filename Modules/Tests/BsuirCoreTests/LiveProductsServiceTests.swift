import XCTest
import Combine
@testable import BsuirCore

// TODO: Write tests
final class LiveProductsServiceTests: XCTestCase {
    private var premiumService: PremiumServiceMock!
    private var sut: LiveProductsService!

    override func setUp() {
        premiumService = PremiumServiceMock()
        sut = LiveProductsService(premiumService: premiumService)
    }

    override func tearDown() {
        sut = nil
        premiumService = nil
    }

    // TODO: test that premium service is updated

    // TODO: test transactions are loaded on load

    // TODO: test products are requested on access to subscription\tips
}

