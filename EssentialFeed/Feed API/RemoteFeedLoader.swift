//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Min on 2020/10/26.
//  Copyright © 2020 Min. All rights reserved.
//

import UIKit

public final class RemoteFeedLoader: FeedLoader {
  private let url: URL
  private let client: HTTPClient

  public enum Error: Swift.Error {
    case connectivity, invalidData
  }

  public typealias Result = LoadFeedResult

  public init(url: URL, client: HTTPClient) {
    self.url = url
    self.client = client
  }

  public func load(completion: @escaping (Result) -> Void) {
    client.get(from: url) { [weak self] result in
      guard self != nil else { return }
      switch result {
        case .success(let result):
          completion(RemoteFeedLoader.map(result.data, from: result.response))
        case .failure:
          completion(.failure(Error.connectivity))
      }
    }
  }

  private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
    do {
      let items = try FeedItemsMapper.map(data, from: response)
      return .success(items.toModels())
    } catch {
      return .failure(error)
    }
  }
}

private extension Array where Element == RemoteFeedItem {
  func toModels() -> [FeedItem] {
    return map { FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) }
  }
}
