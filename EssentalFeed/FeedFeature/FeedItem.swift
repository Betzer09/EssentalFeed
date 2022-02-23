//
//  FeedItem.swift
//  EssentalFeed
//
//  Created by Austin Betzer on 2/9/22.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
