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
        private let currentDate: () -> Date
        
        init(store: FeedStore, currentDate: @escaping () -> Date) {
            self.store = store
            self.currentDate = currentDate
        }
        
        func save(_ items: [FeedItem]) {
            store.deleteCachedFeed { [unowned self] error in
                if error == nil {
                    self.store.insert(items, timestamp: self.currentDate())
                }
            }
        }
    }
    
    class FeedStore {
        var deleteCachedFeedCallCount = 0
        var insertCallCount = 0
        var insertions = [(items: [FeedItem], timestamp: Date)]()
        
        typealias DeletionCompletion = (Error?) -> Void
        private var deletionCompletions = [DeletionCompletion]()
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            deleteCachedFeedCallCount += 1
            deletionCompletions.append(completion)
        }
        
        func completeDeletion(with error: NSError, at index: Int = 0)  {
            deletionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func insert(_ items: [FeedItem], timestamp: Date) {
            insertCallCount += 1
            insertions.append((items, timestamp))
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
    
    func test_save_requestNewCacheInsertionOnSuccessfulDeletion() {
        
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    func test_save_requestNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
        
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
        
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore)  {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
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
