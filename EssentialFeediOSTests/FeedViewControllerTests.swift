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
    loader?.load(completion: { [weak self] _ in
      self?.refreshControl?.endRefreshing()
    })
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

  func test_viewDodLoad_hidesLoadingIndicatorOnLoaderCompletion() {
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeFeedLoading()

    XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
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
    private var completions = [(FeedLoader.Result) -> Void]()

    var loadCallCount: Int {
      return completions.count
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      completions.append(completion)
    }

    func completeFeedLoading() {
      completions[0](.success([]))
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

