//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Min on 2021/4/26.
//  Copyright © 2021 Min. All rights reserved.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {

  public init() {  }

  public func retrieve(completion: @escaping RetrievalCompletion) {
    completion(.empty)
  }

  public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {

  }

  public func deletecachedFeed(completion: @escaping DeletionCompletion) {

  }
}


