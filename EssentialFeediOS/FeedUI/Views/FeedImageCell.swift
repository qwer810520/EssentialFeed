//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Min on 2021/5/19.
//  Copyright © 2021 Min. All rights reserved.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
  public let locationContainer = UIView()
  public let locationLabel = UILabel()
  public let descriptionLabel = UILabel()
  public let feedImageContainer = UIView()
  public let feedImageView = UIImageView()

  public lazy var feedImageRetryButton: UIButton = {
    let button = UIButton()
    button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
    return button
  }()

  var onRetry: (() -> Void)?

  // MARK: - Action Methods

  @objc private func retryButtonTapped() {
    onRetry?()
  }
}
