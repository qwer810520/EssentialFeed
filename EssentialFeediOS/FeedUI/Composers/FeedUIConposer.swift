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
    let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
    let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
    let feedController = FeedViewController(refreshViewController: refreshController)
    presentationAdapter.presenter = FeedPresenter(feedView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader), loadingView: WeakRefVirtualProxy(refreshController))
    return feedController
  }

  private static func adaptFeedToCellControlers(forwardingto controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
    return { [weak controller] feed in
      controller?.tableModel = feed.map { FeedImageCellController(viewModel: FeedImageViewModel(model: $0, imageLoader: loader, imageTransformer: UIImage.init)) }
    }
  }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
  private weak var object: T?

  init(_ object: T) {
    self.object = object
  }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel) {
    object?.display(viewModel)
  }
}

private final class FeedViewAdapter {
  private weak var controller: FeedViewController?
  private let imageLoader: FeedImageDataLoader

  init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
    self.controller = controller
    self.imageLoader = imageLoader
  }
}

  // MARK: - FeedView

extension FeedViewAdapter: FeedView {
  func display(_ viewModel: FeedViewModel) {
    controller?.tableModel = viewModel.feed.map { model in
      FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
    }
  }
}

private final class FeedLoaderPresentationAdapter {

  private let feedLoader: FeedLoader
  var presenter: FeedPresenter?

  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
}

  // MARK: - FeedRefreshViewControllerDelegate

extension FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
  func didRequestFeedRefresh() {
    presenter?.didStartLoadingFeed()

    feedLoader.load { [weak self] result in
      switch result {
        case let .success(feed):
          self?.presenter?.didFinishLoadingFeed(with: feed)
        case let .failure(error):
          self?.presenter?.didFinishLoadingFeed(with: error)
      }
    }
  }
}
