//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Min on 2021/3/17.
//  Copyright © 2021 Min. All rights reserved.
//

import Foundation

func anyNSError() -> NSError {
  return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
  return URL(string: "http://any-url.com")!
}
