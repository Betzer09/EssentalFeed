//
//  LocalFeedLoader.swift
//  EssentalFeed
//
//  Created by Austin Betzer on 3/19/22.
//

import Foundation

public final class LocalFeedLoader {
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    private let calendar = Calendar(identifier: .gregorian)
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else {return}
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, withCompletion: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], withCompletion completion: @escaping (SaveResult) -> ()) {
        store.insert(feed.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else {return}
            completion(error)
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> ()) {
        store.retrieve { [weak self] result in
            guard let self = self else {return}
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(feed, timestamp) where self.validate(timestamp):
                completion(.success(feed.toModels()))
            case .found:
                self.store.deleteCachedFeed(completion: {_ in})
                completion(.success([]))
            case .empty:
                completion(.success([]))    
            }
        }
    }
    
    public func validateCache() {
        store.retrieve(completion: {_ in})
        store.deleteCachedFeed(completion: {_ in })
    }
    
    private var maxCacheAgeInDays: Int {return 7}
    private func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        
        return currentDate() < maxCacheAge
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map {LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map {FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}

