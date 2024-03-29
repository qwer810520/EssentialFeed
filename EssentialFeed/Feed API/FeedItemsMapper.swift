//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Min on 2020/11/11.
//  Copyright © 2020 Min. All rights reserved.
//

import Foundation

 final class FeedItemsMapper {
  private struct Root: Decodable {
    let items: [RemoteFeedItem]
  }

  private static var OK_200: Int { return 200 }

   static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
    guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
      throw RemoteFeedLoader.Error.invalidData
    }
    return root.items
  }
}
