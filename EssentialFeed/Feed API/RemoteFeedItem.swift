//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Min on 2021/3/3.
//  Copyright © 2021 Min. All rights reserved.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
  internal let id: UUID
  internal let description: String?
  internal let location: String?
  internal let image: URL
}
