//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Min on 2020/10/26.
//  Copyright © 2020 Min. All rights reserved.
//

import UIKit

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
