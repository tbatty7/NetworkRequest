//
//  SpyUrlSession.swift
//  NetworkRequestTests
//
//  Created by Timothy D Batty on 2/10/22.
//

@testable import NetworkRequest
import Foundation

private class DummyUrlSessionDataTask: URLSessionDataTask {
    override func resume() {
        
    }
}

class SpyUrlSession: URLSessionProtocol {
    
    var dataTaskCallCount = 0
    var dataTaskArgsRequest: [URLRequest] = []
    var dataTaskArgsCompletionHandler: [(Data?, URLResponse?, Error?) -> Void] = []
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTaskCallCount += 1
        dataTaskArgsRequest.append(request)
        dataTaskArgsCompletionHandler.append(completionHandler)
        return DummyUrlSessionDataTask()
    }
}

func setUpSpy(_ viewController: ViewController) -> SpyUrlSession {
    let spyUrlSession = SpyUrlSession()
    viewController.session = spyUrlSession
    viewController.loadViewIfNeeded()
    return spyUrlSession
}
