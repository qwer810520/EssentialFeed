//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Min on 2021/5/26.
//  Copyright © 2021 Min. All rights reserved.
//

import Foundation

public protocol FeedImageDataLoaderTask {
  func cancel()
}

public protocol FeedImageDataLoader {
  typealias Result = Swift.Result<Data, Error>

  func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}


