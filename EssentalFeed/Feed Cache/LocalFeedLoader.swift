//
//  LocalFeedLoader.swift
//  EssentalFeed
//
//  Created by Austin Betzer on 3/19/22.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else {return}
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, withCompletion: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], withCompletion completion: @escaping (Error?) -> ()) {
        store.insert(items, timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else {return}
            completion(error)
        }
    }
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
}
