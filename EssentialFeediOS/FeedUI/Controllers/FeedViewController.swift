//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Min on 2021/5/14.
//  Copyright © 2021 Min. All rights reserved.
//

import UIKit
import EssentialFeed

public class FeedViewController: UITableViewController {

  private var refreshController: FeedRefreshViewController?
  var tableModel = [FeedImageCellController]() {
    didSet { tableView.reloadData() }
  }

  convenience init(refreshViewController: FeedRefreshViewController) {
    self.init()
    self.refreshController = refreshViewController
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    refreshControl = refreshController?.view

    tableView.prefetchDataSource = self
    refreshController?.refresh()
  }

  // MARK: - Private Methods

  private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
    cellController(forRowAt: indexPath).cancelLoad()
  }

  private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
    return tableModel[indexPath.row]
  }

  // MARK: - UITableViewDataSource

  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableModel.count
  }

  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return cellController(forRowAt: indexPath).view()
  }

  // MARK: - UITableViewDelegate

  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cancelCellControllerLoad(forRowAt: indexPath)
  }
}

  // MARK: - UITableViewDataSourcePrefetching

extension FeedViewController: UITableViewDataSourcePrefetching {
  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      cellController(forRowAt: indexPath).preload()
    }
  }

  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { [weak self] indexPath in
      self?.cancelCellControllerLoad(forRowAt: indexPath)
    }
  }
}
