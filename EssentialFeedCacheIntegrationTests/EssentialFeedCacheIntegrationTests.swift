//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Min on 2021/4/29.
//  Copyright © 2021 Min. All rights reserved.
//

import XCTest
import EssentialFeed

class EssentialFeedCacheIntegrationTests: XCTestCase {

  override func setUp() {
    super.setUp()
    setupEmptyStoreState()
  }

  override func tearDown() {
    super.tearDown()
    undoStoreSideEffects()
  }

  func test_load_deliversNoItemsInEmptyCache() {
    let sut = makeSUT()

    expect(sut, toLoad: [])
  }

  func test_load_deliversItemsSavedOnASeoarateInstance() {
    let sutToPerformSave = makeSUT()
    let sutToPerformLoad = makeSUT()
    let feed = uniqueImageFeed().models

    let saveExp = expectation(description: "Wait for save completion")
    sutToPerformSave.save(feed) { saveError in
      XCTAssertNil(saveError, "Expected to save feed successfully")
      saveExp.fulfill()
    }
    wait(for: [saveExp], timeout: 1.0)

    expect(sutToPerformLoad, toLoad: feed)
  }

  func test_save_overriderItemsSavedOnASeparateInstance() {
    let sutToPerformFirstSave = makeSUT()
    let sutToPerformLastSave = makeSUT()
    let sutToPerformLoad = makeSUT()
    let firstFeed = uniqueImageFeed().models
    let latestFeed = uniqueImageFeed().models

    let saveExp1 = expectation(description: "Wait for save completion")
    sutToPerformFirstSave.save(firstFeed) { saveError in
      XCTAssertNil(saveError, "Expected to save feed successfully")
      saveExp1.fulfill()
    }
    wait(for: [saveExp1], timeout: 1.0)

    let saveExp2 = expectation(description: "Wait for save complection")
    sutToPerformLastSave.save(latestFeed) { saveError in
      XCTAssertNil(saveError, "Expected to save feed successfully")
      saveExp2.fulfill()
    }
    wait(for: [saveExp2], timeout: 1.0)

    expect(sutToPerformLoad, toLoad: latestFeed)
  }

  // MARK: - Helpers

  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
    let storeBundle = Bundle(for: CoreDataFeedStore.self)
    let storeURL = testSpecificStoreURL()
    let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
    let sut = LocalFeedLoader(store: store, currentDate: Date.init)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }

  private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")
    sut.load { result in
      switch result {
        case let .success(imageFeed):
          XCTAssertEqual(imageFeed, expectedFeed, file: file, line: line)
        case let .failure(error):
          XCTFail("Expected successful feed result, got \(error) instead")
      }

      exp.fulfill()
    }

    wait(for: [exp], timeout: 1.0)
  }

  private func testSpecificStoreURL() -> URL {
    return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
  }

  private func cachesDirectory() -> URL {
    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
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
