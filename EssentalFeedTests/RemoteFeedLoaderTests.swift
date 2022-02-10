//
//  EssentalFeedTests.swift
//  EssentalFeedTests
//
//  Created by Austin Betzer on 2/9/22.
//

import XCTest
import EssentalFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        let _ = makeSUT()
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "www.strides.dev")!
        let client = HTTPClientSpy()
        let remoteFeedLoader = makeSUT(url: url, client: client)
        
        remoteFeedLoader.sut.load()
        remoteFeedLoader.sut.load()
        XCTAssertEqual(client.requestURLs, [url, url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "www.strides.dev")!
        let client = HTTPClientSpy()
        let remoteFeedLoader = makeSUT(url: url, client: client)
        
        remoteFeedLoader.sut.load()
        remoteFeedLoader.sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
    private func makeSUT(url: URL = URL(string: "www.strides.dev")!, client: HTTPClient = HTTPClientSpy()) -> (sut: RemoteFeedLoader, client: HTTPClient) {
        let client = client
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        var requestURLs = [URL]()
        
        func get(from url: URL) {
            requestedURL = url
            requestURLs.append(url)
        }
    }

}
