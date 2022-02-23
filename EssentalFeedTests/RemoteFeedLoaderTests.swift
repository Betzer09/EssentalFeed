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
        
        expect(sut: sut, toCompleteWith: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index,code in
            expect(sut: sut, toCompleteWith: .failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJSON = Data("Invalid JSon".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .success([])) {
            let emptyListJSON = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = FeedItem(id: UUID(),
                             description: nil,
                             location: nil,
                             imageURL: URL(string: "www.strides.dev")!)
        
        let itemsJSON1 = [
            "id": item1.id.uuidString,
            "image": item1.imageURL.absoluteString,
        ]
        
        let item2 = FeedItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "www.stridesdevelopment.com")!)
        
        let itemsJSON2 = [
            "id": item2.id.uuidString,
            "image": item2.imageURL.absoluteString,
            "description": item2.description,
            "location": item2.location
        ]
        
        let itemsJSON = [
            "items": [itemsJSON1, itemsJSON2]
        ]
        
        expect(sut: sut, toCompleteWith: .success([item1, item2])) {
            let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
            client.complete(withStatusCode: 200, data: json)
        }
        
    }

    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "www.strides.dev")!,
                         client: HTTPClientSpy = HTTPClientSpy()) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = client
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(sut: RemoteFeedLoader,
                        toCompleteWith result: RemoteFeedLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        
        var capturedResult = [RemoteFeedLoader.Result]()
        sut.load() { capturedResult.append($0)}
        action()
        XCTAssertEqual(capturedResult, [result], file: file, line: line)
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
