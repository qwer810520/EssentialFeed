//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Min on 2021/5/26.
//  Copyright © 2021 Min. All rights reserved.
//

import UIKit

final class FeedRefreshViewController: NSObject {
  private(set) lazy var view = loadView()

  private let loadFeed: () -> Void

  // MARK: - Initialization

  init(loadFeed: @escaping () -> Void) {
    self.loadFeed = loadFeed
  }

  // MARK: - Action Methods

  @objc func refresh() {
    loadFeed()
  }

  // MARK: - Private Methods

  private func loadView() -> UIRefreshControl {
    let view = UIRefreshControl()
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    return view
  }
}

  // MARK: - FeedLoadingView

extension FeedRefreshViewController: FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel) {
    if viewModel.isLoading {
      view.beginRefreshing()
    } else {
      view.endRefreshing()
    }
  }
}
