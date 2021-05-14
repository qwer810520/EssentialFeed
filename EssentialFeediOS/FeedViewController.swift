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
    loader?.load(completion: { [weak self] _ in
      self?.refreshControl?.endRefreshing()
    })
  }
}

