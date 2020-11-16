//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Min on 2020/10/18.
//  Copyright © 2020 Min. All rights reserved.
//

import XCTest
import EssentialFeed


class RemoteFeedLoaderTests: XCTestCase {

  func test_init_doesNotRequestDataFromURL() {
    let (_, client) = makeSUT()

    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

  func test_load_requestsDataFromURL() {
    let url = URL(string: "https://a-given-url.com")!
    let (sut, client) = makeSUT(url: url)

    sut.load() { _ in }

    XCTAssertEqual(client.requestedURLs, [url])
  }

  func test_loadTwice_requestsDataFromURLTwice() {
    let url = URL(string: "https://a-given-url.com")!
    let (sut, client) = makeSUT(url: url)

    sut.load() { _ in }
    sut.load() { _ in }

    XCTAssertEqual(client.requestedURLs, [url, url])
  }

  func test_load_deliversErrorOnClientError() {
    let (sut, client) = makeSUT()

    expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.connectivity)) {
      let clientError = NSError(domain: "Test", code: 0)
      client.complecte(with: clientError)
    }
  }

  func test_load_deliversErrorOnNon200HTTPResponse() {
    let (sut, client) = makeSUT()

    let sample = [199, 201, 300, 400, 500]

    sample.enumerated().forEach { index, code in
      expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.invalidData)) {
        let json = makeItemJSON([])
        client.complecte(withStatusCode: code, data: json, at: index)
      }
    }
  }

  func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
    let (sut, client) = makeSUT()

    expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.invalidData)) {
      let invalidJSON = Data("invalid JSON".utf8)
      client.complecte(withStatusCode: 200, data: invalidJSON)
    }
  }

  func test_load_deliversNoItemsOn200HTTPTesponseWithEmptyJSONList() {
    let (sut, client) = makeSUT()

    expect(sut, toCompleteWith: .success([])) {
      let emptyListJson = makeItemJSON([])
      client.complecte(withStatusCode: 200, data: emptyListJson)
    }
  }

  func test_load_deliversItemsOn200HTTPResponseWithJsonItems() {
    let (sut, client) = makeSUT()

    let item1 = makeItem(id: UUID(), imageURL: URL(string: "http://a-url.com")!)

    let item2 = makeItem(id: UUID(), description: "a description", location: "a location", imageURL: URL(string: "http://another-url.com")!)

    let items = [item1.model, item2.model]

    expect(sut, toCompleteWith: .success(items)) {
      let json = makeItemJSON([item1.json, item2.json])
      client.complecte(withStatusCode: 200, data: json)
    }
  }

  func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
    let url = URL(string: "http://any-url.com")!
    let client = HTTPClientSpy()
    var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)

    var capturedResults = [RemoteFeedLoader.Result]()
    sut?.load { capturedResults.append($0) }

    sut = nil
    client.complecte(withStatusCode: 200, data: makeItemJSON([]))

    XCTAssert(capturedResults.isEmpty)
  }

  // MARK: - Helpers

  private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedLoader(url: url, client: client)
    trackForMemoryLeaks(client, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, client)
  }

  private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
    addTeardownBlock { [weak instance] in
      XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
    }
  }

  private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
    let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
    let json = [
      "id": id.uuidString,
      "description": description,
      "location": location,
      "image": imageURL.absoluteString
    ].reduce(into: [String: Any]()) { if let value = $1.value { $0[$1.key] = value } }

    return (item, json)
  }

  private func makeItemJSON(_ items: [[String: Any]]) -> Data {
    let json = ["items": items]
    return try! JSONSerialization.data(withJSONObject: json)
  }

  private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {

    let exp = expectation(description: "Wait for load completion")

    sut.load { receivedResult in
      switch (receivedResult, expectedResult) {
        case let (.success(receivedItems), .success(expectedItems)):
          XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
        case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
          XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        default:
          XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
      }

      exp.fulfill()
    }

    action()

    wait(for: [exp], timeout: 1.0)
  }

  private class HTTPClientSpy: HTTPClient {
    private var messages = [(url: URL, complection: (HTTPClientResult) -> Void)]()

    var requestedURLs: [URL] {
      return messages.map { $0.url }
    }

    func get(from url: URL, complectilon: @escaping (HTTPClientResult) -> Void) {
      messages.append((url, complectilon))
    }

    func complecte(with error: Error, at index: Int = 0) {
      messages[index].complection(.failure(error))
    }

    func complecte(withStatusCode code: Int, data: Data, at index: Int = 0) {
      guard let response = HTTPURLResponse(
              url: requestedURLs[index],
              statusCode: code,
              httpVersion: nil,
              headerFields: nil) else { return }

      messages[index].complection(.success((data, response)))
    }
  }
}
