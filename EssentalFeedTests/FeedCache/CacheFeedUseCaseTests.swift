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
        
        func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
            store.deleteCachedFeed { [unowned self] error in
                completion(error)
                if error == nil {
                    self.store.insert(items, timestamp: self.currentDate())
                }
            }
        }
    }
    
    class FeedStore {
        
        typealias DeletionCompletion = (Error?) -> Void
        private var deletionCompletions = [DeletionCompletion]()
        
        enum ReceivedMessage: Equatable {
            case deleteCacheFeed
            case insert([FeedItem], Date)
        }
        private(set) var receivedMessages = [ReceivedMessage]()
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            deletionCompletions.append(completion)
            receivedMessages.append(.deleteCacheFeed)
        }
        
        func completeDeletion(with error: NSError, at index: Int = 0)  {
            deletionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func insert(_ items: [FeedItem], timestamp: Date) {
            receivedMessages.append(.insert(items, timestamp))
        }
    }
    
    func test_init_doesNotMessageTheStoreUponCreate() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items) {_ in}
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(items) {_ in}
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
        
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(items) {_ in}
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [ .deleteCacheFeed, .insert(items, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        let exp = expectation(description: "Wait for save completion")
        var receivedError: Error?
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletionSuccessfully()
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(store.receivedMessages, [ .deleteCacheFeed, .insert(items, timestamp)])
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
