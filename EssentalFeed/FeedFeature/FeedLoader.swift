//
//  FeedLoader.swift
//  EssentalFeed
//
//  Created by Austin Betzer on 2/9/22.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> ())
}
