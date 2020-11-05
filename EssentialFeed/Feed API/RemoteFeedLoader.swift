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
          if result.response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: result.data) {
            complection(.success(root.items))
          } else {
            complection(.failure(.invalidData))
          }
        case .failure:
          complection(.failure(.connectivity))
      }
    }
  }
}

private struct Root: Decodable {
  let items: [FeedItem]
}

