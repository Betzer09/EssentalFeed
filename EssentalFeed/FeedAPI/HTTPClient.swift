//
//  HTTPClient.swift
//  EssentalFeed
//
//  Created by Austin Betzer on 2/23/22.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> ())
}
