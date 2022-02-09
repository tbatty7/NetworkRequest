@testable import NetworkRequest
import XCTest

final class ViewControllerTests: XCTestCase {

    func test_zero() throws {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: ViewController = storyboard.instantiateViewController(identifier: String(describing: ViewController.self))
        let mockUrlSession = MockUrlSession()
        viewController.session = mockUrlSession
        viewController.loadViewIfNeeded()
        
        tap(viewController.button)
        
        XCTAssertEqual(mockUrlSession.dataTaskCallCount, 1)
        
    }
}
