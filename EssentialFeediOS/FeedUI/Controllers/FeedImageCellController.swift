//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Min on 2021/5/26.
//  Copyright © 2021 Min. All rights reserved.
//

import UIKit

protocol FeedImageCellControllerDelegate {
  func didRequestImage()
  func didCancelImageRequest()
}

final class FeedImageCellController {

  private let delegate: FeedImageCellControllerDelegate
  private lazy var cell = FeedImageCell()

  init(delegate: FeedImageCellControllerDelegate) {
    self.delegate = delegate
  }

  func view() -> UITableViewCell {
    delegate.didRequestImage()
    return cell
  }

  func preload() {
    delegate.didRequestImage()
  }

  func cancelLoad() {
    delegate.didCancelImageRequest()
  }
}

  // MARK: - FeedImageView

extension FeedImageCellController: FeedImageView {
  func display(_ viewModel: FeedImageViewModel<UIImage>) {
    cell.locationContainer.isHidden = !viewModel.hasLocation
    cell.locationLabel.text = viewModel.location
    cell.descriptionLabel.text = viewModel.description
    cell.feedImageView.image = viewModel.image
    cell.feedImageContainer.isShimmering = viewModel.isLocation
    cell.feedImageRetryButton.isHidden = !viewModel.shouldRetry
    cell.onRetry = delegate.didRequestImage
  }
}
