//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Min on 2021/6/22.
//  Copyright © 2021 Min. All rights reserved.
//

import Foundation
import EssentialFeed

struct FeedImageViewModel<Image> {
  let description: String?
  let location: String?
  let image: Image?
  let isLocation: Bool
  let shouldRetry: Bool

  var hasLocation: Bool {
    return location != nil
  }
}

protocol FeedImageView {
  associatedtype Image

  func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {

  private let view: View
  private let imageTransformer: (Data) -> Image?

  // MARK: - Initialization

  init(view: View, imageTransformer: @escaping (Data) -> Image?) {
    self.view = view
    self.imageTransformer = imageTransformer
  }

  func didStartLoadingImageData(with model: FeedImage) {
    view.display(FeedImageViewModel(
                  description: model.description,
                  location: model.location,
                  image: nil,
                  isLocation: true,
                  shouldRetry: false))
  }

  struct InvalidImageDataError: Error { }

  func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
    guard let image = imageTransformer(data) else {
      return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
    }

    view.display(FeedImageViewModel(
                  description: model.description,
                  location: model.location,
                  image: image,
                  isLocation: false,
                  shouldRetry: false))
  }

  func didFinishLoadingImageData(with error: Error, for model: FeedImage){
    view.display(FeedImageViewModel(
                  description: model.description,
                  location: model.location,
                  image: nil,
                  isLocation: false,
                  shouldRetry: true))
  }

}
