//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Min on 2020/10/26.
//  Copyright © 2020 Min. All rights reserved.
//

import Foundation

public typealias HTTPClientResult = Result<HTTPURLResponse, Error>

public protocol HTTPClient {
  func get(from url: URL, complectilon: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
  private let url: URL
  private let client: HTTPClient

  public enum Error: Swift.Error {
    case connectivity, invalidData
  }

  public init(url: URL, client: HTTPClient) {
    self.url = url
    self.client = client
  }

  public func load(complection: @escaping (Error) -> Void) {
    client.get(from: url) { result in
      switch result {
        case .success:
          complection(.invalidData)
        case .failure:
          complection(.connectivity)
      }
    }
  }
}

