//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Min on 2021/5/10.
//  Copyright © 2021 Min. All rights reserved.
//

import XCTest

class FeedViewController {

  init(loader: FeedViewControllerTests.LoaderSpy) {

  }
}

class FeedViewControllerTests: XCTestCase {

  func test_init_doesNotLoadFeed() {
    let loader = LoaderSpy()
    _ = FeedViewController(loader: loader)

    XCTAssertEqual(loader.loadCallCount, 0)
  }

  // MARK: - Helpers

  class LoaderSpy {
    private(set) var loadCallCount: Int = 0
  }
}

