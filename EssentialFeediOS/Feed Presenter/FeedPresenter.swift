//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Min on 2021/6/21.
//  Copyright © 2021 Min. All rights reserved.
//

import Foundation
import EssentialFeed

struct FeedLoadingViewModel {
  let isLoading: Bool
}

protocol FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
  let feed: [FeedImage]
}

protocol FeedView {
  func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
  typealias Observer<T> = (T) -> Void

  var feedView: FeedView?
  var loadingView:  FeedLoadingView?

  private let feedLoader: FeedLoader

  // MARK: - Initialization

  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }

  func loadFeed() {
    loadingView?.display(FeedLoadingViewModel(isLoading: true))

    feedLoader.load { [weak self] result in
      if let feed = try? result.get() {
        self?.feedView?.display(FeedViewModel(feed: feed))
      }
      self?.loadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
  }
}
