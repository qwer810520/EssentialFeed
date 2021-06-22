//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Min on 2021/5/26.
//  Copyright © 2021 Min. All rights reserved.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
  func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject {
  private(set) lazy var view = loadView()

  private let delegate: FeedRefreshViewControllerDelegate

  // MARK: - Initialization

  init(delegate: FeedRefreshViewControllerDelegate) {
    self.delegate = delegate
  }

  // MARK: - Action Methods

  @objc func refresh() {
    delegate.didRequestFeedRefresh()
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
