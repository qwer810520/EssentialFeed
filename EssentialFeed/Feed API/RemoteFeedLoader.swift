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
          completion(FeedItemsMapper.map(result.data, from: result.response))
        case .failure:
          completion(.failure(Error.connectivity))
      }
    }
  }
}
