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
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "www.strides.dev")!
        let client = HTTPClientSpy()
        let remoteFeedLoader = makeSUT(url: url, client: client)
        
        remoteFeedLoader.sut.load { _ in}
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "www.strides.dev")!
        let client = HTTPClientSpy()
        let remoteFeedLoader = makeSUT(url: url, client: client)
        
        remoteFeedLoader.sut.load { _ in}
        remoteFeedLoader.sut.load { _ in}
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedError = [RemoteFeedLoader.Error?]()
        
        
        sut.load() { capturedError.append($0)}
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    private func makeSUT(url: URL = URL(string: "www.strides.dev")!,
                         client: HTTPClientSpy = HTTPClientSpy()) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = client
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            return messages.map( { $0.url })
        }
        
        private var messages = [(url: URL, completion: (Error) -> ())]()
        
        func get(from url: URL, completion: @escaping (Error) -> ()) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error)
        }
    }

}
