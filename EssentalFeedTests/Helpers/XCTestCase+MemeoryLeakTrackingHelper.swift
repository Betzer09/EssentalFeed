//
//  XCTestCase+MemeoryLeakTrackingHelper.swift
//  EssentalFeedTests
//
//  Created by Austin Betzer on 3/1/22.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
    }
}
