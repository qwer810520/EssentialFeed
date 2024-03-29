//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Min on 2021/4/22.
//  Copyright © 2021 Min. All rights reserved.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
  func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieve: .success(.none), file: file, line: line)
  }

  func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
  }

  func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let feed = uniqueImageFeed().local
    let timestamp = Date()

    insert((feed, timestamp), to: sut)

    expect(sut, toRetrieve: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
  }

  func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let feed = uniqueImageFeed().local
    let timestamp = Date()

    insert((feed, timestamp), to: sut)

    expect(sut, toRetrieveTwice: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
  }

  func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)

    XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
  }

  func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    insert((uniqueImageFeed().local, Date()), to: sut)

    let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)

    XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
  }

  func assertThatInsertOverridesPrevionslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
    insert((uniqueImageFeed().local, Date()), to: sut)

    let latestFeed = uniqueImageFeed().local
    let latestTimestamp = Date()
    insert((latestFeed, latestTimestamp), to: sut)

    expect(sut, toRetrieve: .success(CachedFeed(feed: latestFeed, timestamp: latestTimestamp)), file: file, line: line)
  }

  func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let deletionError = deleteCache(from: sut)

    XCTAssertNil(deletionError, "Expected empty cache deletion on succed", file: file, line: line)
  }

  func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    deleteCache(from: sut)

    expect(sut, toRetrieve: .success(.none), file: file, line: line)
  }

  func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    insert((uniqueImageFeed().local, Date()), to: sut)

    let deletionError = deleteCache(from: sut)

    XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
  }

  func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    insert((uniqueImageFeed().local, Date()), to: sut)

    deleteCache(from: sut)

    expect(sut, toRetrieve: .success(.none), file: file, line: line)
  }

  func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    var completionOperationsInOrder: [XCTestExpectation] = []

    let op1 = expectation(description: "Operation 1")
    sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
      completionOperationsInOrder.append(op1)
      op1.fulfill()
    }

    let op2 = expectation(description: "Operation 2")
    sut.deletecachedFeed { _ in
      completionOperationsInOrder.append(op2)
      op2.fulfill()
    }

    let op3 = expectation(description: "Operation 3")
    sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
      completionOperationsInOrder.append(op3)
      op3.fulfill()
    }

    waitForExpectations(timeout: 5.0)

    XCTAssertEqual(completionOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
  }
}

extension FeedStoreSpecs where Self: XCTestCase {
  @discardableResult
  func deleteCache(from sut: FeedStore) -> Error? {
    let exp = expectation(description: "Wait for cache deletion")
    var deletionError: Error?
    sut.deletecachedFeed { result in
      if case let Result.failure(error) = result {
        deletionError = error
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return deletionError
  }

  @discardableResult
  func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
    let exp = expectation(description: "Wait for cache insertion")
    var insertionError: Error?
    sut.insert(cache.feed, timestamp: cache.timestamp) { result in
      if case let Result.failure(error) = result {
        insertionError = error
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return insertionError
  }

  func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrieveResult, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }

  func expect(_ sut: FeedStore, toRetrieve expectedResult: FeedStore.RetrieveResult, file: StaticString = #filePath, line: UInt = #line) {
    let exp = expectation(description: "Wait for cache retrieval")

    sut.retrieve { retrievedResult in
      switch (expectedResult, retrievedResult) {
        case (.success(.none), .success(.none)), (.failure, .failure):
          break
        case let (.success(.some(ecpected)), .success(.some(retrieved))):
          XCTAssertEqual(ecpected.feed, retrieved.feed, file: file, line: line)
          XCTAssertEqual(ecpected.timestamp, retrieved.timestamp, file: file, line: line)
        default:
          XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
      }
      exp.fulfill()
    }

    wait(for: [exp], timeout: 1.0)
  }

}
