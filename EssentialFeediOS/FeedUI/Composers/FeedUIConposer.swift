//
//  FeedUIConposer.swift
//  EssentialFeediOS
//
//  Created by Min on 2021/5/26.
//  Copyright © 2021 Min. All rights reserved.
//

import UIKit
import EssentialFeed

public final class FeedUIConposer {

  private init() {}

  public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
    let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
    let feedController = FeedViewController(refreshViewController: refreshController)
    refreshController.onRefresh = adaptFeedToCellControlers(forwardingto: feedController, loader: imageLoader)
    return feedController
  }

  private static func adaptFeedToCellControlers(forwardingto controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
    return { [weak controller] feed in
      controller?.tableModel = feed.map { FeedImageCellController(model: $0, imageLoader: loader) }
    }
  }
}
