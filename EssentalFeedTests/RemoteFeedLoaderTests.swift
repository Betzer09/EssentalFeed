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
        
        expect(sut: sut, toCompleteWithError: .connectivity) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index,code in
            expect(sut: sut, toCompleteWithError: .invalidData) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWithError: .invalidData) {
            let invalidJSON = Data("Invalid JSon".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    private func makeSUT(url: URL = URL(string: "www.strides.dev")!,
                         client: HTTPClientSpy = HTTPClientSpy()) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = client
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(sut: RemoteFeedLoader, toCompleteWithError error: RemoteFeedLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        var capturedError = [RemoteFeedLoader.Error?]()
        sut.load() { capturedError.append($0)}
        action()
        XCTAssertEqual(capturedError, [error], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            return messages.map( { $0.url })
        }
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> ())]()
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> ()) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            
            messages[index].completion(.success(data, response))
        }
    }

}
