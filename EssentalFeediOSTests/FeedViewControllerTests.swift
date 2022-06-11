//
//  FeedViewControllerTests.swift
//  EssentalFeediOSTests
//
//  Created by Austin Betzer on 6/11/22.
//

import XCTest

final class FeedViewController {
    init(loader: FeedViewControllerTests.LoaderSpy) {
        
    }
}

class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
        
    }
    
    // MARK: - Helpers
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }
}
