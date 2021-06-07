//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Min on 2021/6/7.
//  Copyright © 2021 Min. All rights reserved.
//

import Foundation
import EssentialFeed

final class FeedViewModel {


  var onChange: ((FeedViewModel) -> Void)?
  var onFeedLoad: (([FeedImage]) -> Void)?

  private(set) var isLoading: Bool = false {
    didSet { onChange?(self) }
  }

  private let feedLoader: FeedLoader

  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }

  func loadFeed() {
    self.isLoading = true
    feedLoader.load { [weak self] result in
      if let feed = try? result.get() {
        self?.onFeedLoad?(feed)
      }

      self?.isLoading = false
    }
  }
}
