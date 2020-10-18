//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Min on 2020/10/18.
//  Copyright © 2020 Min. All rights reserved.
//

import XCTest

class RemoteFeedLoader {
  func load() {
    HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")
  }
}

class HTTPClient {
  var requestedURL: URL?

  static let shared = HTTPClient()

   private init() { }
}

class RemoteFeedLoaderTests: XCTestCase {

  func test_init_doesNotRequestDataFromURL() {
    let client = HTTPClient.shared

    let _ = RemoteFeedLoader()

    XCTAssertNil(client.requestedURL)
  }

  func test_load_requestDataFromURL() {
    let client = HTTPClient.shared
    let sut = RemoteFeedLoader()

    sut.load()

    XCTAssertNotNil(client.requestedURL)
  }
}
