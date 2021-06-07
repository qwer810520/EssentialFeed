//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Min on 2021/6/7.
//  Copyright © 2021 Min. All rights reserved.
//

import Foundation
import EssentialFeed

final class FeedImageViewModel<Image> {

  typealias Observer<T> = (T) -> Void

  private var task: FeedImageDataLoaderTask?
  private let model: FeedImage
  private let imageLoader: FeedImageDataLoader
  private let imageTransformer: (Data) -> Image?

  var description: String? {
    return model.description
  }

  var location: String? {
    return model.location
  }

  var hasLocation: Bool {
    return location != nil
  }

  var onImageLoad: Observer<Image>?
  var onImageLoadingStateChange: Observer<Bool>?
  var onShouldRetryImageLoadStateChange: Observer<Bool>?

  // MARK: - Initialization

  init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
    self.model = model
    self.imageLoader = imageLoader
    self.imageTransformer = imageTransformer
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
    if let image = (try? result.get()).flatMap(imageTransformer) {
      onImageLoad?(image)
    } else {
      onShouldRetryImageLoadStateChange?(true)
    }

    onImageLoadingStateChange?(false)
  }
}
