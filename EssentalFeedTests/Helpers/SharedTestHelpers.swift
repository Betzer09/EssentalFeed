//
//  SharedTestHelpers.swift
//  EssentalFeedTests
//
//  Created by Austin Betzer on 4/4/22.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any erro", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}
