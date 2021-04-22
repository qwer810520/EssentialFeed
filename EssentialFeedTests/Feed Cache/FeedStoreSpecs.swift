//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Min on 2021/4/22.
//  Copyright © 2021 Min. All rights reserved.
//

import Foundation

protocol FeedStoreSpecs {
  func test_retrieve_deliversEmptyOnEnptyCache()
  func test_retrieve_hasNoSideEffectsOnEmptyCache()
  func test_retrieve_deliversFoundValuesOnNonEmptyCache()
  func test_retrieve_hasNoSideEffectsOnNonEmptyCache()

  func test_insert_deliversNoErrorInEmptyCache()
  func test_insert_deliversNoErrorOnNonEmptyCache()
  func test_insert_overridesPreviouslyInsertedCacheValues()

  func test_delete_deliversNoErrorOnEmptyCache()
  func test_delete_hasNoSideEffectsOnEmptyCache()
  func test_delete_deliversNoErrorOnNonEmptyCache()
  func test_delete_emptiesPreviouslyInsertionCache()

  func test_storeSideEffects_runSerially()
}

protocol FailableRetrueveFeedStoreSpecs: FeedStoreSpecs {
  func test_retrieve_deliversFailureOnRetrievalError()
  func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailableInsertFeedstoreSpecs: FeedStoreSpecs {
  func test_insert_deliversErrorOnInsertionError()
  func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
  func test_delete_deliversErrorOnDeletionError()
  func test_delete_hasNoSideEffectsOnDeletionError()
}

typealias FailableFeedStore = FailableRetrueveFeedStoreSpecs & FailableInsertFeedstoreSpecs & FailableDeleteFeedStoreSpecs

