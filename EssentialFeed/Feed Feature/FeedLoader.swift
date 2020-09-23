//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Min on 2020/9/23.
//  Copyright © 2020 Min. All rights reserved.
//

import Foundation

protocol FeedLoader {
  func load(completion: @escaping (Result<[FeedItem], Error>) -> Void)
}
