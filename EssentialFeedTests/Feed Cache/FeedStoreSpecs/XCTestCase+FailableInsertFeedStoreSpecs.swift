//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Min on 2021/4/22.
//  Copyright © 2021 Min. All rights reserved.
//

import XCTest
import EssentialFeed

extension FailableInsertFeedstoreSpecs where Self: XCTestCase {
  func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)

    XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
  }

  func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    insert((uniqueImageFeed().local, Date()), to: sut)

    expect(sut, toRetrieve: .success(.none), file: file, line: line)
  }
}
