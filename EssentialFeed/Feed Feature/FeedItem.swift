//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Min on 2020/9/23.
//  Copyright © 2020 Min. All rights reserved.
//

import Foundation

public struct FeedItem: Equatable {
  let id: UUID
  let description: String?
  let location: String?
  let imageURL: URL
}
