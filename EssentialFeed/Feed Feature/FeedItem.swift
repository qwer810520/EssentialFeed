//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Min on 2020/9/23.
//  Copyright © 2020 Min. All rights reserved.
//

import Foundation

public struct FeedItem: Equatable {
  public let id: UUID
  public let description: String?
  public let location: String?
  public let imageURL: URL

  public init(id: UUID, description: String?, location: String?, imageURL: URL) {
    self.id = id
    self.description = description
    self.location = location
    self.imageURL = imageURL
  }
}
