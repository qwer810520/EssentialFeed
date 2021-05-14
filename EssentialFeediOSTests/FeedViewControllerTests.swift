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
    load()
  }

  // MARK: - Action Methods

  @objc private func load() {
    refreshControl?.beginRefreshing()
    loader?.load(completion: { [weak self] _ in
      self?.refreshControl?.endRefreshing()
    })
  }
}

class FeedViewControllerTests: XCTestCase {

  func test_loadFeedAction_requestFeedFromLoader() {
    let (sut, loader) = makeSUT()
    XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")

    sut.loadViewIfNeeded()
    XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")

    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a load")

    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading request once user initiates another load")
  }

  func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

    loader.completeFeedLoading(at: 0)
    XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")

    sut.simulateUserInitiatedFeedReload()
    XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

    loader.completeFeedLoading(at: 1)
    XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed")
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

    func completeFeedLoading(at index: Int) {
      completions[index](.success([]))
    }
  }
}

private extension FeedViewController {
  func simulateUserInitiatedFeedReload() {
    refreshControl?.simulatePullToRefresh()
  }

  var isShowingLoadingIndicator: Bool {
    return refreshControl?.isRefreshing == true
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

