//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Min on 2021/4/22.
//  Copyright © 2021 Min. All rights reserved.
//

import XCTest
import EssentialFeed

extension FailableRetrueveFeedStoreSpecs where Self: XCTestCase {
  func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
  }

  func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
  }
}

