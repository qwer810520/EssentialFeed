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

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
  func display(_ viewModel: FeedImageViewModel<UIImage>) {
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
      let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
      let view = FeedImageCellController(delegate: adapter)
      adapter.presenter = FeedImagePresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
      return view
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

private final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image> where View.Image == Image {
  private let model: FeedImage
  private let imageLoader: FeedImageDataLoader
  private var task: FeedImageDataLoaderTask?

  var presenter: FeedImagePresenter<View, Image>?

  init(model: FeedImage, imageLoader: FeedImageDataLoader) {
    self.model = model
    self.imageLoader = imageLoader
  }

}

extension FeedImageDataLoaderPresentationAdapter: FeedImageCellControllerDelegate {
  func didRequestImage() {
    presenter?.didStartLoadingImageData(with: model)

    let model = model
    task = imageLoader.loadImageData(from: model.url, completion: { [weak self] result in
      switch result {
        case let .success(data):
          self?.presenter?.didFinishLoadingImageData(with: data, for: model)
        case let .failure(error):
          self?.presenter?.didFinishLoadingImageData(with: error, for: model)
      }
    })
  }

  func didCancelImageRequest() {
    task?.cancel()
  }
}
