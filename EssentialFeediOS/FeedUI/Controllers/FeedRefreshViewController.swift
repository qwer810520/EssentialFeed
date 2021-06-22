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

  private let presenter: FeedPresenter

  // MARK: - Initialization

  init(presenter: FeedPresenter) {
    self.presenter = presenter
  }

  // MARK: - Action Methods

  @objc func refresh() {
    presenter.loadFeed()
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
  func display(isLoading: Bool) {
    if isLoading {
      view.beginRefreshing()
    } else {
      view.endRefreshing()
    }
  }
}
