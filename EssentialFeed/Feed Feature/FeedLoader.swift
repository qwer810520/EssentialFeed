//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Min on 2020/9/23.
//  Copyright © 2020 Min. All rights reserved.
//

import Foundation

public protocol FeedLoader {
  typealias Result = Swift.Result<[FeedImage], Error>

  func load(completion: @escaping (Result) -> Void)
}
