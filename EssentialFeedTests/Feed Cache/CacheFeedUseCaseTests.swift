//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Min on 2021/1/20.
//  Copyright © 2021 Min. All rights reserved.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
  private let store: FeedStore

  init(store: FeedStore) {
    self.store = store
  }

  func save(_ items: [FeedItem]) {
    store.deletecachedFeed()
  }
}

class FeedStore {
  var deleteCachedFeedCallCount = 0

  func deletecachedFeed() {
    deleteCachedFeedCallCount += 1
  }
}

class CacheFeedUseCaseTests: XCTestCase {

  func test_init_doesNotDeleteCacheUponCreation() {
    let (_, store) = makeSUT()
    _ = LocalFeedLoader(store: store)

    XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
  }

  func test_save_requestsCasheDeletion() {
    let items = [uniqueItem(), uniqueItem()]
    let (sut, store) = makeSUT()

    sut.save(items)

    XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
  }

  // MARK: - Helpers

  private func makeSUT() -> (sut: LocalFeedLoader, store: FeedStore) {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store)
    return (sut, store)
  }

  private func uniqueItem() -> FeedItem {
    return FeedItem(id: UUID(), description: "any", location: "anu", imageURL: anyURL())
  }

  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }
}
