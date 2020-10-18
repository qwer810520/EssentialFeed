//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Min on 2020/10/18.
//  Copyright © 2020 Min. All rights reserved.
//

import XCTest

class RemoteFeedLoader {

}

class HTTPClient {
  var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

  func test_init_doesNotRequestDataFromURL() {
    let client = HTTPClient()

    let _ = RemoteFeedLoader()

    XCTAssertNil(client.requestedURL)
  }
}
