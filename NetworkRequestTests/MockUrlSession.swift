//
//  MockUrlSession.swift
//  NetworkRequestTests
//
//  Created by Timothy D Batty on 2/9/22.
//

import Foundation
@testable import NetworkRequest

class MockUrlSession: URLSessionProtocol {
    
    var dataTaskCallCount = 0
    var dataTaskArgsRequest: [URLRequest] = []
    
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        dataTaskCallCount += 1
        dataTaskArgsRequest.append(request)
        return DummyUrlSessionDataTask()
    }
    
}

private class DummyUrlSessionDataTask: URLSessionDataTask {
    override func resume() {
        // do nothing
    }
}
