//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Min on 2021/5/26.
//  Copyright © 2021 Min. All rights reserved.
//

import UIKit
import EssentialFeed

final class FeedRefreshViewController: NSObject {

  private(set) lazy var view: UIRefreshControl = {
    let view = UIRefreshControl()
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    return view
  }()

  private let feedLoader: FeedLoader
  var onRefresh: (([FeedImage]) -> Void)?

  // MARK: - Initialization

  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }

  // MARK: - Action Methods

  @objc func refresh() {
    view.beginRefreshing()
    feedLoader.load(completion: { [weak self] result in
      if let feed = try? result.get() {
        self?.onRefresh?(feed)
      }
      self?.view.endRefreshing()
    })
  }
}
