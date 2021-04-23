//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Min on 2021/4/23.
//  Copyright © 2021 Min. All rights reserved.
//

import XCTest
import EssentialFeed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
  func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let deletionError = deleteCache(from: sut)

    XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
  }

  func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    deleteCache(from: sut)

    expect(sut, toRetrieve: .empty, file: file, line: line)
  }
}
