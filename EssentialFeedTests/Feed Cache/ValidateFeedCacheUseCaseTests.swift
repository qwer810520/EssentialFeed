//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Min on 2021/3/17.
//  Copyright © 2021 Min. All rights reserved.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {

  func test_load_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()

    XCTAssertEqual(store.receivedMessages, [])
  }

  func test_validateCache_deletesCacheOnRetrievalError() {
    let (sut, store) = makeSUT()
    
    sut.validateCache()
    store.completeRetrieval(with: anyNSError())

    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
  }

  // MARK: - Helpers

  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(store)
    trackForMemoryLeaks(sut)
    return (sut, store)
  }

  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
}
