//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Min on 2021/5/26.
//  Copyright © 2021 Min. All rights reserved.
//

import UIKit

final class FeedImageCellController {

  private let viewModel: FeedImageViewModel

  init(viewModel: FeedImageViewModel) {
    self.viewModel = viewModel
  }

  func view() -> UITableViewCell {
    let cell = binded(FeedImageCell())
    viewModel.loadImageData()
    return cell
  }

  func preload() {
    viewModel.loadImageData()
  }

  func cancelLoad() {
    viewModel.cancelImageDataLoad()
  }

  // MARK: - Private Methods

  private func binded(_ cell: FeedImageCell) -> FeedImageCell {
    cell.locationContainer.isHidden = !viewModel.hasLocation
    cell.locationLabel.text = viewModel.location
    cell.descriptionLabel.text = viewModel.description
    cell.onRetry = viewModel.loadImageData

    viewModel.onImageLoad = { [weak cell] image in
      cell?.feedImageView.image = image
    }

    viewModel.onImageLoadingStateChange = { [weak cell] isLoacing in
      cell?.feedImageContainer.isShimmering = isLoacing
    }

    viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
      cell?.feedImageRetryButton.isHidden = !shouldRetry
    }

    return cell
  }
}
