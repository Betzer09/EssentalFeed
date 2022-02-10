//
//  EssentalFeedTests.swift
//  EssentalFeedTests
//
//  Created by Austin Betzer on 2/9/22.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from:  URL(string: "www.strides.dev"))
    }
}

class HTTPClient {
    static var shared = HTTPClient()
    
    func get(from url: URL?) { }
}

class HTTPClientSpy: HTTPClient {
    
    override func get(from url: URL?) {
        requestedURL = url
    }
    
    var requestedURL: URL?
}



class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }

}
