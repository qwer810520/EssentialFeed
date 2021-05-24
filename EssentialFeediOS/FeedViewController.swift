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

  private var loader: FeedLoader?
  private var tableModel = [FeedImage]()

  public convenience init(loader: FeedLoader) {
    self.init()
    self.loader = loader
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
    loader?.load(completion: { [weak self] result in
      switch result {
        case let .success(feed):
          self?.tableModel = feed
          self?.tableView.reloadData()
          self?.refreshControl?.endRefreshing()
        case .failure: break
      }
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
    return cell
  }
}
