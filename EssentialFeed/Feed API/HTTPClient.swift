//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Min on 2020/11/11.
//  Copyright © 2020 Min. All rights reserved.
//

import Foundation

public typealias HTTPClientResult = Result<(data: Data, response: HTTPURLResponse), Error>

public protocol HTTPClient {
  func get(from url: URL, complectilon: @escaping (HTTPClientResult) -> Void)
}
