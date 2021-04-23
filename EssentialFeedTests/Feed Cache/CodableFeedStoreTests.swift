//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Min on 2021/4/15.
//  Copyright © 2021 Min. All rights reserved.
//

import XCTest
@testable import EssentialFeed

class CodableFeedStoreTests: XCTestCase, FailableFeedStore {

  override func setUp() {
    super.setUp()
    setupEmptyStoreState()
  }

  override func tearDown() {
    super.tearDown()
    undoStoreSideEffects()
  }

  func test_retrieve_deliversEmptyOnEnptyCache() {
    let sut = makeSUT()

    assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
  }

  func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()

    assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
  }

  func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
    let sut = makeSUT()

    assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
  }

  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()

    assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
  }

  func test_retrieve_deliversFailureOnRetrievalError() {
    let storeURL = testSpecificStoreURL()
    let sut = makeSUT(storeURL: storeURL)

    try! "invalid data".write(to: storeURL, atomically: true, encoding: .utf8)

    assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
  }

  func test_retrieve_hasNoSideEffectsOnFailure() {
    let storeURL = testSpecificStoreURL()
    let sut = makeSUT()

    try! "invalid data".write(to: storeURL, atomically: true, encoding: .utf8)

    assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
  }

  func test_insert_deliversNoErrorInEmptyCache() {
    let sut = makeSUT()

    assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
  }

  func test_insert_deliversNoErrorOnNonEmptyCache() {
    let sut = makeSUT()

    assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
  }

  func test_insert_overridesPreviouslyInsertedCacheValues() {
    let sut = makeSUT()

    assertThatInsertOverridesPrevionslyInsertedCacheValues(on: sut)
  }

  func test_insert_deliversErrorOnInsertionError() {
    let invalidStoreURL = URL(string: "invalid://store-url")!
    let sut = makeSUT(storeURL: invalidStoreURL)

    assertThatInsertDeliversErrorOnInsertionError(on: sut)
  }

  func test_insert_hasNoSideEffectsOnInsertionError() {
    let invalidStoreURL = URL(string: "invalid://store-url")!
    let sut = makeSUT(storeURL: invalidStoreURL)

    assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
  }

  func test_delete_deliversNoErrorOnEmptyCache() {
    let sut = makeSUT()

    assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
  }

  func test_delete_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()

    assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
  }

  func test_delete_deliversNoErrorOnNonEmptyCache() {
    let sut = makeSUT()

    assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
  }

  func test_delete_emptiesPreviouslyInsertionCache() {
    let sut = makeSUT()

    assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
  }

  func test_delete_deliversErrorOnDeletionError() {
    let noDeletePermissionURL = cachesDirectory()
    let sut = makeSUT(storeURL: noDeletePermissionURL)

    assertThatDeleteDeliversErrorOnDeletionError(on: sut)
  }

  func test_delete_hasNoSideEffectsOnDeletionError() {
    let noDeletePermissionURL = cachesDirectory()
    let sut = makeSUT(storeURL: noDeletePermissionURL)

    assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
  }

  func test_storeSideEffects_runSerially() {
    let sut = makeSUT()

    assertThatSideEffectsRunSerially(on: sut)
  }

  // MARK: - Helper

  private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
    let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }

  private func testSpecificStoreURL() -> URL {
    return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
  }

  private func cachesDirectory() -> URL {
    guard let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
      fatalError("Not find the cache url")
    }
    return storeURL
  }

  private func setupEmptyStoreState() {
    deleteStoreArtifacts()
  }

  private func undoStoreSideEffects() {
    deleteStoreArtifacts()
  }

  private func deleteStoreArtifacts() {
    try? FileManager.default.removeItem(at: testSpecificStoreURL())
  }

}
