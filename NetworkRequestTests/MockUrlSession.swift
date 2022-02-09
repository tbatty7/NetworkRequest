//
//  MockUrlSession.swift
//  NetworkRequestTests
//
//  Created by Timothy D Batty on 2/9/22.
//

import Foundation
import XCTest
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
    
    func verifyDataTask(with request: URLRequest, file: StaticString = #file, line: UInt = #line) {
        guard dataTaskWasCalledOnce(file: file, line: line) else  {
            return
        }
        
        XCTAssertEqual(dataTaskArgsRequest.first, request, "request", file: file, line: line)
    }
    
    private func dataTaskWasCalledOnce(file: StaticString = #file, line: UInt = #line) -> Bool {
        verifyMethodCallOnce(methodName: "dataTask(with:completionHandler:)", callCount: dataTaskCallCount, describeArgument: "request: \(dataTaskArgsRequest)", namedFile: file, line: line)
    }
}

private class DummyUrlSessionDataTask: URLSessionDataTask {
    override func resume() {
        // do nothing
    }
}

func verifyMethodCallOnce(methodName: String, callCount: Int, describeArgument: @autoclosure () -> String, namedFile: StaticString = #file, line: UInt = #line) -> Bool {
    if callCount == 0 {
        XCTFail("Wanted but not invoked \(methodName)", file: namedFile, line: line)
        return false
    }
    
    if callCount > 1 {
        XCTFail("Wanted 1 time but was called \(callCount) times. \(methodName) with \(describeArgument())", file: namedFile, line: line)
        return false
    }
    
    return true
}
