@testable import NetworkRequest
import XCTest

final class ViewControllerTests: XCTestCase {

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
    
    func test_searchForBookNetworkCall_withSuccessResponse_shouldSaveDataInResults() {
        let viewController: ViewController = createViewController()
        let spyUrlSession: SpyUrlSession = setUpSpy(viewController)
        let handleResultsCalled = expectation(description: "handleResults called")
        viewController.handleResults = { _ in handleResultsCalled.fulfill() }
        
        tap(viewController.button)
        spyUrlSession.dataTaskArgsCompletionHandler.first?(jsonData(), response(statusCode: 200), nil)
        waitForExpectations(timeout: 0.01)
        
        XCTAssertEqual(viewController.results, [SearchResult(artistName: "Artist", trackName: "Track", collectionPrice: 2.5, primaryGenreName: "Rock")])
    }
    
    func test_searchForBookNetworkCall_withSuccessResponse_shouldNotSaveDataInResults() {
        let viewController: ViewController = createViewController()
        let spyUrlSession: SpyUrlSession = setUpSpy(viewController)
                
        tap(viewController.button)

        spyUrlSession.dataTaskArgsCompletionHandler.first?(jsonData(), response(statusCode: 200), nil)
        
        XCTAssertEqual(viewController.results, [])
    }
                
    private func createViewController() -> ViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(identifier: String(describing: ViewController.self))
    }
    
    private func jsonData() -> Data {
        """
        {
            "results": [
                {
                    "artistName": "Artist",
                    "trackName": "Track",
                    "collectionPrice": 2.5,
                    "primaryGenreName": "Rock"
                }
            ]
        }
        """.data(using: .utf8)!
    }
    
    private func response(statusCode: Int) -> HTTPURLResponse? {
        HTTPURLResponse(url: URL(string: "http://food.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
    }
}
