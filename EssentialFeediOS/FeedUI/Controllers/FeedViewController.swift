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
  private var imageLoader: FeedImageDataLoader?
  private var tableModel = [FeedImage]() {
    didSet { tableView.reloadData() }
  }
  private var cellControllers: [IndexPath: FeedImageCellController] = [:]

  public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
    self.init()
    self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
    self.imageLoader = imageLoader
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    refreshControl = refreshController?.view
    refreshController?.onRefresh = { [weak self] feed in
      self?.tableModel = feed
    }

    tableView.prefetchDataSource = self
    refreshController?.refresh()
  }

  // MARK: - Private Methods

  private func removeCellController(forRowAt indexPath: IndexPath) {
    cellControllers[indexPath] = nil
  }

  private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
    let cellModel = tableModel[indexPath.row]
    let cellController = FeedImageCellController(model: cellModel, imageLoader: imageLoader!)
    cellControllers[indexPath] = cellController
    return cellController
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
    removeCellController(forRowAt: indexPath)
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
      self?.removeCellController(forRowAt: indexPath)
    }
  }
}
