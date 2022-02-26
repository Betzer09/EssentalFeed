//
//  URLSessionHTTPClientTests.swift
//  EssentalFeedTests
//
//  Created by Austin Betzer on 2/26/22.
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_createsDataWithURL() {
        let url = URL(string: "www.strides.dev")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        XCTAssertEqual(session.receivedURLS, [url])
    }
    
    // MARK: - Helpers
    private class URLSessionSpy: URLSession {
        var receivedURLS = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLS.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {}

}
