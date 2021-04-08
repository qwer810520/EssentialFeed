//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Min on 2021/4/8.
//  Copyright © 2021 Min. All rights reserved.
//

import Foundation

internal final class FeedCachePolicy {

  private static let calendar = Calendar(identifier: .gregorian)

  private static var maxCacheAgeInDays: Int {
    return 7
  }

  private init() { }

  internal static func validate(_ timestamp: Date, against date: Date) -> Bool {
    let calendar = Calendar(identifier: .gregorian)
    guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
    return date < maxCacheAge
  }
}

