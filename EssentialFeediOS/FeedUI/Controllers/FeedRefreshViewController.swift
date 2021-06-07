//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Min on 2021/5/26.
//  Copyright © 2021 Min. All rights reserved.
//

import UIKit

final class FeedRefreshViewController: NSObject {
  private(set) lazy var view = binded(UIRefreshControl())

  private let viewModel: FeedViewModel

  // MARK: - Initialization

  init(viewModel: FeedViewModel) {
    self.viewModel = viewModel
  }

  // MARK: - Action Methods

  @objc func refresh() {
    viewModel.loadFeed()
  }

  // MARK: - Private Methods

  private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
    viewModel.onLoadingStateChange = { [weak view] isLoading in
      if isLoading {
        view?.beginRefreshing()
      } else {
        view?.endRefreshing()
      }
    }

    view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    return view
  }
}
