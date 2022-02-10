@testable import NetworkRequest
import XCTest

final class ViewControllerTests: XCTestCase {
    
    private func createViewController() -> ViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(identifier: String(describing: ViewController.self))
    }
    
    func test_assertOneRequestSentWithQueryParamsInSpecificOrder() throws {
        let viewController: ViewController = createViewController()
        let mockUrlSession: MockUrlSession = setUpMock(viewController)
        
        tap(viewController.button)
        
        let expectedRequest = URLRequest(url: URL(string: "https://itunes.apple.com/search?mediaType=book&term=out%20from%20boneville")!)
        mockUrlSession.verifyDataTask(with: expectedRequest)
    }
    
    func test_assertQueryParamsInAnyOrder() {
        let viewController: ViewController = createViewController()
        let mockUrlSession: MockUrlSession = setUpMock(viewController)
        
        tap(viewController.button)
        
        let expectedUrl = URL(string: "https://itunes.apple.com/search")!
        mockUrlSession.verifyDataTask(with: expectedUrl, queryList: ["term=out%20from%20boneville", "mediaType=book"])
    }
}
