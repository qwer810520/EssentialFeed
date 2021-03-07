//
//  LoadFeedFormCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Min on 2021/3/7.
//  Copyright © 2021 Min. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {

  func test_init_doesNotMessageStoreUpenCreation() {
    let (_, store) = makeSUT()

    XCTAssertEqual(store.receivedMessages, [])
  }

  func test_load_requestsCacheRetrieval() {
    let (sut, store) = makeSUT()

    sut.load()

    XCTAssertEqual(store.receivedMessages, [.retrieve])

  }

  // MARK: - Helpers

  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
  }
}
