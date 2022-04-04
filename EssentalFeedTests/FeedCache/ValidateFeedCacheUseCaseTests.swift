//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentalFeedTests
//
//  Created by Austin Betzer on 4/4/22.
//

import XCTest
import EssentalFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageTheStoreUponCreate() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy)  {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
}
