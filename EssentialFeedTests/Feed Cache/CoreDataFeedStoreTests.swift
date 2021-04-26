//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Min on 2021/4/26.
//  Copyright © 2021 Min. All rights reserved.
//

import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {

  func test_retrieve_deliversEmptyOnEnptyCache() {
    let sut = makeSUT()

    assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
  }

  func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()

    assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
  }

  func test_retrieve_deliversFoundValuesOnNonEmptyCache() {

  }

  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {

  }

  func test_insert_deliversNoErrorInEmptyCache() {

  }

  func test_insert_deliversNoErrorOnNonEmptyCache() {

  }

  func test_insert_overridesPreviouslyInsertedCacheValues() {

  }

  func test_delete_deliversNoErrorOnEmptyCache() {

  }

  func test_delete_hasNoSideEffectsOnEmptyCache() {

  }

  func test_delete_deliversNoErrorOnNonEmptyCache() {

  }

  func test_delete_emptiesPreviouslyInsertionCache() {

  }

  func test_storeSideEffects_runSerially() {

  }

  // MARK: - Helper

  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
    let bundle = Bundle(for: CoreDataFeedStore.self)
    let sut = try! CoreDataFeedStore(bundle: bundle)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
}