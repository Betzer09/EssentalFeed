//
//  FeedStore.swift
//  EssentalFeed
//
//  Created by Austin Betzer on 3/19/22.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func retrieve()
}


