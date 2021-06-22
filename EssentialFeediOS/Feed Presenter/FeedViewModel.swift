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

  typealias Observer<T> = (T) -> Void

  var onLoadingStateChange: Observer<Bool>?
  var onFeedLoad: Observer<[FeedImage]>?

  private let feedLoader: FeedLoader

  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }

  func loadFeed() {
    onLoadingStateChange?(true)
    feedLoader.load { [weak self] result in
      if let feed = try? result.get() {
        self?.onFeedLoad?(feed)
      }

      self?.onLoadingStateChange?(false)
    }
  }
}
