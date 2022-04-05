//
//  FeedStoreSpy.swift
//  EssentalFeedTests
//
//  Created by Austin Betzer on 4/1/22.
//

import Foundation
import EssentalFeed

class FeedStoreSpy: FeedStore {
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var loadCompletions = [RetrievalCompletion]()
    
    enum ReceivedMessage: Equatable {
        case deleteCacheFeed
        case insert([LocalFeedImage], Date)
        case retrieve
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
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func completeInsertion(with error: NSError?, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items, timestamp))
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        loadCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        loadCompletions[index](.empty)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        loadCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        loadCompletions[index](.found(feed: feed, timestamp: timestamp))
    }
}
