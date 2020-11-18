//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Min on 2020/11/18.
//  Copyright © 2020 Min. All rights reserved.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
  private let session: URLSession

  init(session: URLSession) {
    self.session = session
  }

  func get(form url: URL) {
    session.dataTask(with: url) { _, _, _ in }
  }
}

class URLSessionHTTPClientTests: XCTestCase {

  func test_getFromURL_createsDataTaskWithURL() {
    let url = URL(string: "http://any-url.com")!
    let session = URLSessionSpy()
    let sut = URLSessionHTTPClient(session: session)

    sut.get(form: url)

    XCTAssertEqual(session.receivedURLs, [url])
  }

  // MARK: - Helpers

  private class URLSessionSpy: URLSession {
    var receivedURLs = [URL]()

    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
      receivedURLs.append(url)
      return FakeURLSessionDataTask()
    }
  }

  private class FakeURLSessionDataTask: URLSessionDataTask { }
}
