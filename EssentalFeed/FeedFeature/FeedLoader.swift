//
//  FeedLoader.swift
//  EssentalFeed
//
//  Created by Austin Betzer on 2/9/22.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping (FeedLoader.Result) -> Void)
}
