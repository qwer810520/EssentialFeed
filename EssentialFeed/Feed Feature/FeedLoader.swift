//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Min on 2020/9/23.
//  Copyright © 2020 Min. All rights reserved.
//

import Foundation

//public typealias LoadFeedResult = Swift.Result<[FeedItem], Error>

public enum LoadFeedResult<Error: Swift.Error> {
  case success([FeedItem])
  case failure(Error)
}

protocol FeedLoader {
  associatedtype Error: Swift.Error

  func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
