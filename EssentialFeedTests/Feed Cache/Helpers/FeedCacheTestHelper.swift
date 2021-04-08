//
//  FeedCacheTestHelper.swift
//  EssentialFeedTests
//
//  Created by Min on 2021/3/17.
//  Copyright © 2021 Min. All rights reserved.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
  return FeedImage(id: UUID(), description: "any", location: "anu", url: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
  let models = [uniqueImage(), uniqueImage()]
  let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
  return (models, local)
}

extension Date {
  private var feedCacheMaxAgeInDays: Int {
    return 7
  }

  func minusFeedCacheMaxAge() -> Date {
    return adding(days: -feedCacheMaxAgeInDays)
  }

  private func adding(days: Int) -> Date {
    guard let newDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self) else { fatalError() }
    return newDate
  }
}

extension Date {
  func adding(seconds: TimeInterval) -> Date {
    return self + seconds
  }
}
