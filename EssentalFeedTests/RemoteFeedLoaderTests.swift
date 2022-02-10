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
        XCTAssertTrue(client.requestURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "www.strides.dev")!
        let client = HTTPClientSpy()
        let remoteFeedLoader = makeSUT(url: url, client: client)
        
        remoteFeedLoader.sut.load()
        XCTAssertEqual(client.requestURLs, [url])
    }
    
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "www.strides.dev")!
        let client = HTTPClientSpy()
        let remoteFeedLoader = makeSUT(url: url, client: client)
        
        remoteFeedLoader.sut.load()
        remoteFeedLoader.sut.load()
        
        XCTAssertEqual(client.requestURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedError: RemoteFeedLoader.Error?
        client.error = NSError(domain: "Test", code: 0)
        
        sut.load() { error in
            capturedError = error
        }
        
        XCTAssertEqual(capturedError, .connectivity)
    }
    
    private func makeSUT(url: URL = URL(string: "www.strides.dev")!,
                         client: HTTPClientSpy = HTTPClientSpy()) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = client
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestURLs = [URL]()
        var error: Error?
        
        func get(from url: URL, completion: @escaping (Error) -> ()) {
            if let error = error {
                completion(error)
            }
            requestURLs.append(url)
        }
    }

}
