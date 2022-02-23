//
//  RemoteFeedLoader.swift
//  EssentalFeed
//
//  Created by Austin Betzer on 2/9/22.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> ()) {
        client.get(from:  url) { result in
            
            switch result {
            case .failure:
                completion(.failure(.connectivity))
            case .success:
                completion(.failure(.invalidData))
            }
        }
    }
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> ())
}
