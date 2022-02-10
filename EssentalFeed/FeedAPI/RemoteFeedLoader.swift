//
//  RemoteFeedLoader.swift
//  EssentalFeed
//
//  Created by Austin Betzer on 2/9/22.
//

import Foundation

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.get(from:  url)
    }
}

public protocol HTTPClient {
    func get(from url: URL?)
}
