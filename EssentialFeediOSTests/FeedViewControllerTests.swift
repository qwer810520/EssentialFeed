//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Min on 2021/5/10.
//  Copyright © 2021 Min. All rights reserved.
//

import XCTest
import UIKit
import EssentialFeed

class FeedViewController: UITableViewController {

  private var loader: FeedLoader?

  convenience init(loader: FeedLoader) {
    self.init()
    self.loader = loader
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    refreshControl?.beginRefreshing()
    load()
  }

  // MARK: - Action Methods

  @objc private func load() {
    loader?.load(completion: { _ in })
  }
}

class FeedViewControllerTests: XCTestCase {

  func test_init_doesNotLoadFeed() {
    let (_, loader) = makeSUT()

    XCTAssertEqual(loader.loadCallCount, 0)
  }

  func test_viewDidLoad_loadsFeed() {
    let (sut, loader) = makeSUT()
    sut.loadViewIfNeeded()

    sut.refreshControl?.simulatePullToRefresh()
    XCTAssertEqual(loader.loadCallCount, 2)

    sut.refreshControl?.simulatePullToRefresh()
    XCTAssertEqual(loader.loadCallCount, 3)
  }

  func test_viewDidLoad_showsLoadingIndicator() {
    let (sut, _) = makeSUT()

    sut.loadViewIfNeeded()

    XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
  }

  // MARK: - Helpers

  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
    let loader = LoaderSpy()
    let sut = FeedViewController(loader: loader)
    trackForMemoryLeaks(loader, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, loader)
  }

  class LoaderSpy: FeedLoader {
    private(set) var loadCallCount: Int = 0

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      loadCallCount += 1
    }
  }
}

private extension UIRefreshControl {
  func simulatePullToRefresh() {
    allTargets.forEach { target in
      actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
        (target as NSObject).perform(Selector($0))
      }
    }
  }
}

