//
//  CacheFeedUseCaseTests.swift
//  EssentalFeedTests
//
//  Created by Austin Betzer on 3/15/22.
//

import XCTest
import EssentalFeed

class CacheFeedUseCaseTests: XCTestCase {

    class LocalFeedLoader {
        private let store: FeedStore
        
        init(store: FeedStore) {
            self.store = store
        }
        
        func save(_ items: [FeedItem]) {
            store.deleteCachedFeed()
        }
    }
    
    class FeedStore {
        var deleteCachedFeedCallCount = 0
        var insertCallCount = 0
        
        func deleteCachedFeed() {
            deleteCachedFeedCallCount += 1
        }
        
        func completeDeletion(with: NSError) {
            
        }
    }
    
    func test_init_doesNotDeleteCacheUponCreate() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore)  {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any erro", code: 0)
    }
    
    func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }

}
