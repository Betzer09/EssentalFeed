//
//  LoadFeedFromCacheUseCaseTest.swift
//  EssentalFeedTests
//
//  Created by Austin Betzer on 4/1/22.
//

import XCTest
import EssentalFeed


class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageTheStoreUponCreate() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load() {_ in}
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        var receivedError: Error?
        
        let exp = expectation(description: "Wait for load completion")
        sut.load() { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        store.completeRetrieval(with: retrievalError)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, retrievalError)
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        var receivedImages: [FeedImage]?

        let exp = expectation(description: "Wait for load completion")
        sut.load() { result in
            switch result {
            case let .success(images):
                receivedImages = images
            default:
                XCTFail("Expected success, got \(result) instead")
            }
            
            exp.fulfill()
        }

        store.completeRetrievalWithEmptyCache()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedImages, [])
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy)  {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any erro", code: 0)
    }
    
}
