//
//  CacheFeedUseCaseTests.swift
//  EssentalFeedTests
//
//  Created by Austin Betzer on 3/15/22.
//

import XCTest

class CacheFeedUseCaseTests: XCTestCase {

    class LocalFeedLoader {
        init(store: FeedStore) {
            
        }
    }
    
    class FeedStore {
        var deleteCachedFeedCallCount = 0
    }
    
    func test_init_doesNotDeleteCacheUponCreate() {
        let store = FeedStore()
        let _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

}
