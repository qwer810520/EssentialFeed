//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Min on 2021/1/30.
//  Copyright © 2021 Min. All rights reserved.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
  typealias DeletionError = Result<Void, Error>
  typealias DeletionCompletion = (DeletionError) -> Void

  typealias InsertionResult = Result<Void, Error>
  typealias InsertionCompletion = (InsertionResult) -> Void

  typealias RetrieveResult = Swift.Result<CachedFeed?, Error>
  typealias RetrievalCompletion = (RetrieveResult) -> Void

  /// The completion handler can be invoked in any thread.
  /// Clients are responseible to dispatch to appropriate threads, if needed.
  func retrieve(completion: @escaping RetrievalCompletion)

  /// The completion handler can be invoked in any thread.
  /// Clients are responseible to dispatch to appropriate threads, if needed.
  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)

  /// The completion handler can be invoked in any thread.
  /// Clients are responseible to dispatch to appropriate threads, if needed.
  func deletecachedFeed(completion: @escaping DeletionCompletion)
}
