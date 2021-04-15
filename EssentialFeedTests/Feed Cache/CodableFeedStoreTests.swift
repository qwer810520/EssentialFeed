//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Min on 2021/4/15.
//  Copyright © 2021 Min. All rights reserved.
//

import XCTest
@testable import EssentialFeed

class CodableFeedStore {

  private struct Cache: Codable {
    let feed: [LocalFeedImage]
    let timestamp: Date
  }

  private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")

  func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
    guard let data = try? Data(contentsOf: storeURL) else {
      return completion(.empty)
    }

    let decoder = JSONDecoder()
    do {
      let cache = try decoder.decode(Cache.self, from: data)
      completion(.found(feed: cache.feed, timestamp: cache.timestamp))
    } catch {
      completion(.failure(error))
    }
  }

  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
    let encoder = JSONEncoder()
    do {
      let encoded = try encoder.encode(Cache(feed: feed, timestamp: timestamp))
      try encoded.write(to: storeURL)
      completion(nil)
    } catch {
      completion(error)
    }
  }
}

class CodableFeedStoreTests: XCTestCase {

  override func setUp() {
    super.setUp()
    let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    try? FileManager.default.removeItem(at: storeURL)
  }

  func test_retrieve_deliversEmptyOnEnpayCache() {
    let sut = CodableFeedStore()
    let exp = expectation(description: "Wait for cache retrieve")

    sut.retrieve { result in
      switch result {
        case .empty: break
        default:
          XCTFail("Expected empty result, got \(result) instead")
      }
      exp.fulfill()
    }

    wait(for: [exp], timeout: 1.0)
  }

  func test_retrieve_hasNoSideEffectOnEmptyCache() {
    let sut = CodableFeedStore()
    let exp = expectation(description: "Wait for cache retrieve")

    sut.retrieve { firstResult in
      sut.retrieve { secondResult in
        switch (firstResult, secondResult) {
          case (.empty, .empty): break
          default:
            XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
        }
        exp.fulfill()
      }
    }

    wait(for: [exp], timeout: 1.0)
  }

  func test_retrieveAfterInsertingToEmpryCache_deliversInsertedValues() {
    let sut = CodableFeedStore()
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    let exp = expectation(description: "Wait for cache retrieval")

    sut.insert(feed, timestamp: timestamp) { insertionError in
      XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
      sut.retrieve { retrieveResult in
        switch retrieveResult {
          case let .found(retrievedFeed, retirevedTimestamp):
            XCTAssertEqual(retrievedFeed, feed)
            XCTAssertEqual(retirevedTimestamp, timestamp)
          default:
            XCTFail("Expected found result with feed \(feed) and timestamp \(timestamp), got \(retrieveResult) instead")
        }
        exp.fulfill()
      }
    }

    wait(for: [exp], timeout: 1.0)
  }

}
