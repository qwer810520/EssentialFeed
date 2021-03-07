//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Min on 2021/3/7.
//  Copyright © 2021 Min. All rights reserved.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {

  enum ReceivedMessage: Equatable {
    case deleteCachedFeed
    case insert([LocalFeedImage], Date)
    case retrieve
  }

  private(set) var receivedMessages = [ReceivedMessage]()
  private var deletionCompletions = [DeletionCompletion]()
  private var insertionCompletions = [InsertionCompletion]()

  func deletecachedFeed(completion: @escaping DeletionCompletion) {
    deletionCompletions.append(completion)
    receivedMessages.append(.deleteCachedFeed)
  }

  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](error)
  }

  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletions[index](nil)
  }

  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    insertionCompletions.append(completion)
    receivedMessages.append(.insert(feed, timestamp))

  }

  func completeInsertion(with error: Error, at index: Int = 0) {
    insertionCompletions[index](error)
  }

  func completeInsertionSuccessfully(at index: Int = 0) {
    insertionCompletions[index](nil)
  }

  func retrieve() {
    receivedMessages.append(.retrieve)
  }
}
