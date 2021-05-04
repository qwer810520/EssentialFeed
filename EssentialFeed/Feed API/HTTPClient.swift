//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Min on 2020/11/11.
//  Copyright © 2020 Min. All rights reserved.
//

import Foundation

public protocol HTTPClient {
  typealias Result = Swift.Result<(data: Data, response: HTTPURLResponse), Error>

  /// The completion handler can be invoked in any thread.
  /// Clients are responseible to dispatch to appropriate threads, if needed.
  func get(from url: URL, completion: @escaping (Result) -> Void)
}


