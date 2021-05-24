//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Min on 2021/5/14.
//  Copyright © 2021 Min. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol FeedImageDataLoaderTask {
  func cancel()
}

public protocol FeedImageDataLoader {
  func loadImageData(from url: URL) -> FeedImageDataLoaderTask
}

public class FeedViewController: UITableViewController {

  private var feedLoader: FeedLoader?
  private var imageLoader: FeedImageDataLoader?
  private var tableModel = [FeedImage]()
  private var tasks: [IndexPath: FeedImageDataLoaderTask] = [:]

  public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
    self.init()
    self.feedLoader = feedLoader
    self.imageLoader = imageLoader
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    load()
  }

  // MARK: - Action Methods

  @objc private func load() {
    refreshControl?.beginRefreshing()
    feedLoader?.load(completion: { [weak self] result in
      if let feed = try? result.get() {
        self?.tableModel = feed
        self?.tableView.reloadData()
      }
      self?.refreshControl?.endRefreshing()
    })
  }

  // MARK: - UITableViewDataSource

  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableModel.count
  }

  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellModel = tableModel[indexPath.row]
    let cell = FeedImageCell()
    cell.locationContainer.isHidden = (cellModel.location == nil)
    cell.locationLabel.text = cellModel.location
    cell.descriptionLabel.text = cellModel.description
    tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.url)
    return cell
  }

  // MARK: - UITableViewDelegate

  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    tasks[indexPath]?.cancel()
    tasks[indexPath] = nil
  }
}
