//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Min on 2021/6/7.
//  Copyright © 2021 Min. All rights reserved.
//

import UIKit
import EssentialFeed

final class FeedImageViewModel {

  typealias Observer<T> = (T) -> Void

  private var task: FeedImageDataLoaderTask?
  private let model: FeedImage
  private let imageLoader: FeedImageDataLoader

  var description: String? {
    return model.description
  }

  var location: String? {
    return model.location
  }

  var hasLocation: Bool {
    return location != nil
  }

  var onImageLoad: Observer<UIImage>?
  var onImageLoadingStateChange: Observer<Bool>?
  var onShouldRetryImageLoadStateChange: Observer<Bool>?

  // MARK: - Initialization

  init(model: FeedImage, imageLoader: FeedImageDataLoader) {
    self.model = model
    self.imageLoader = imageLoader
  }

  func loadImageData() {
    onImageLoadingStateChange?(true)
    onShouldRetryImageLoadStateChange?(false)

    task = imageLoader.loadImageData(from: model.url, completion: { [weak self] result in
      self?.handle(result)
    })
  }

  func cancelImageDataLoad() {
    task?.cancel()
    task = nil
  }

  // MARK: - Private Methods

  private func handle(_ result: FeedImageDataLoader.Result) {
    if let image = (try? result.get()).flatMap(UIImage.init) {
      onImageLoad?(image)
    } else {
      onShouldRetryImageLoadStateChange?(true)
    }

    onImageLoadingStateChange?(false)
  }
}
