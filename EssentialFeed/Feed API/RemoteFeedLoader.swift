//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Min on 2020/10/26.
//  Copyright © 2020 Min. All rights reserved.
//

import UIKit

public typealias HTTPClientResult = Result<(data: Data, response: HTTPURLResponse), Error>

public protocol HTTPClient {
  func get(from url: URL, complectilon: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
  private let url: URL
  private let client: HTTPClient

  public enum Error: Swift.Error {
    case connectivity, invalidData
  }

  public enum Result: Equatable {
    case success([FeedItem])
    case failure(Error)
  }

  public init(url: URL, client: HTTPClient) {
    self.url = url
    self.client = client
  }

  public func load(complection: @escaping (Result) -> Void) {
    client.get(from: url) { result in
      switch result {
        case .success(let result):
          do {
            let item = try FeedItemsMapper.map(result.data, result.response)
            complection(.success(item))
          } catch {
            complection(.failure(.invalidData))
          }
        case .failure:
          complection(.failure(.connectivity))
      }
    }
  }
}

private class FeedItemsMapper {
  private struct Root: Decodable {
    let items: [Item]
  }

  private struct Item: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL

    var item: FeedItem {
      return FeedItem(id: id, description: description, location: location, imageURL: image)
    }
  }

  static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
    guard response.statusCode == 200 else {
      throw RemoteFeedLoader.Error.invalidData
    }

    let root = try JSONDecoder().decode(Root.self, from: data)
    return root.items.map { $0.item }
  }
}
