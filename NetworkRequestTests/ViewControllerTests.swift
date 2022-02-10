@testable import NetworkRequest
import XCTest
import ViewControllerPresentationSpy

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
    
    func test_searchForBookNetworkCall_withSuccessResponse_withoutWait_shouldNotSaveDataInResults() {
        let viewController: ViewController = createViewController()
        let spyUrlSession: SpyUrlSession = setUpSpy(viewController)
                
        tap(viewController.button)

        spyUrlSession.dataTaskArgsCompletionHandler.first?(jsonData(), response(statusCode: 200), nil)
        
        XCTAssertEqual(viewController.results, [])
    }
    
    func test_searchForBookNetworkCall_withFailureResponse_shouldShowTheAlert() {
        let viewController: ViewController = createViewController()
        let spyUrlSession: SpyUrlSession = setUpSpy(viewController)
        let alertVerifier: AlertVerifier = createAlertVerifierForAsync()
        
        tap(viewController.button)
        spyUrlSession.dataTaskArgsCompletionHandler.first?(nil, nil, TestError(message: "Oh no!"))
        waitForExpectations(timeout: 0.01)
        
        verifyErrorAlert(verifier: alertVerifier, viewController: viewController, message: "Oh no!")
    }
    
    func test_searchForBookNetworkCall_withMalformedData_shouldNotShowTheAlert() {
        let viewController: ViewController = createViewController()
        let spyUrlSession: SpyUrlSession = setUpSpy(viewController)
        let alertVerifier: AlertVerifier = createAlertVerifierForAsync()
        
        tap(viewController.button)
        spyUrlSession.dataTaskArgsCompletionHandler.first?("{ dfkadsfkj }".data(using: .utf8), response(statusCode: 200), nil)
        waitForExpectations(timeout: 0.01)
        
        verifyErrorAlert(verifier: alertVerifier, viewController: viewController, message: "The data couldn’t be read because it isn’t in the correct format.")
    }
    
    func test_searchForBookNetworkCall_withInternalServerErrorResponse_shouldNotShowTheAlert() {
        let viewController: ViewController = createViewController()
        let spyUrlSession: SpyUrlSession = setUpSpy(viewController)
        let alertVerifier: AlertVerifier = createAlertVerifierForAsync()
        
        tap(viewController.button)
        spyUrlSession.dataTaskArgsCompletionHandler.first?("{}".data(using: .utf8), response(statusCode: 500), nil)
        waitForExpectations(timeout: 0.01)
        
        verifyErrorAlert(verifier: alertVerifier, viewController: viewController, message: "Response: internal server error")
    }
    
    func test_searchForBookNetworkCall_withFailureResponse_withoutWait_shouldNotShowTheAlert() {
        let viewController: ViewController = createViewController()
        let spyUrlSession: SpyUrlSession = setUpSpy(viewController)
        let alertVerifier: AlertVerifier = AlertVerifier()
        
        tap(viewController.button)
        spyUrlSession.dataTaskArgsCompletionHandler.first?(nil, nil, TestError(message: "Oh no!"))
        
        XCTAssertEqual(alertVerifier.presentedCount, 0)
    }
    
    func test_assertButtonIsDisabledAfterTap() throws {
        let viewController: ViewController = createViewController()
        let mockUrlSession: MockUrlSession = setUpMock(viewController)
        
        XCTAssertTrue(viewController.button.isEnabled)
        
        tap(viewController.button)
                
        XCTAssertFalse(viewController.button.isEnabled)
    }
    
    func test_searchForBookNetworkCall_withSuccessResponse_shouldEnableButtonAgain() {
        let viewController: ViewController = createViewController()
        let spyUrlSession: SpyUrlSession = setUpSpy(viewController)
        let handleResultsCalled = expectation(description: "handleResults called")
        viewController.handleResults = { _ in handleResultsCalled.fulfill() }
        
        tap(viewController.button)
        spyUrlSession.dataTaskArgsCompletionHandler.first?(jsonData(), response(statusCode: 200), nil)
        waitForExpectations(timeout: 0.01)
        
        XCTAssertTrue(viewController.button.isEnabled)
    }
    
    func test_searchForBookNetworkCall_withSuccessResponse_withoutWait_shouldNotEnableButton() {
        let viewController: ViewController = createViewController()
        let spyUrlSession: SpyUrlSession = setUpSpy(viewController)
        
        tap(viewController.button)
        spyUrlSession.dataTaskArgsCompletionHandler.first?(jsonData(), response(statusCode: 200), nil)

        XCTAssertFalse(viewController.button.isEnabled)
    }
                
    private func createViewController() -> ViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(identifier: String(describing: ViewController.self))
    }
    
    private func createAlertVerifierForAsync() -> AlertVerifier {
        let alertVerifier = AlertVerifier()
        let alertShown = expectation(description: "alert shown")
        alertVerifier.testCompletion = { alertShown.fulfill() }
        
        return alertVerifier
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
    
    private func verifyErrorAlert(verifier: AlertVerifier, viewController : ViewController, message: String, file: StaticString = #file, line: UInt = #line) {
        verifier.verify(title: "Network Problem", message: message, animated: true, actions: [.default("OK")], presentingViewController: viewController, file: file, line: line)
        
        XCTAssertEqual(verifier.preferredAction?.title, "OK", "preferred action", file: file, line: line)
    }
}
