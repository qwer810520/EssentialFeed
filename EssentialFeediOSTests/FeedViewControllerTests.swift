//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Min on 2021/5/10.
//  Copyright © 2021 Min. All rights reserved.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

class FeedViewControllerTests: XCTestCase {

  func test_loadFeedActions_requestFeedFromLoader() {
    let (sut, loader) = makeSUT()
    XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")

    sut.loadViewIfNeeded()
    XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")

    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a load")

    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected a third loading request once user initiates another load")
  }

  func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

    loader.completeFeedLoading(at: 0)
    XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

    sut.simulateUserInitiatedFeedReload()
    XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

    loader.completeFeedLoadingWithError(at: 1)
    XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
  }

  func test_loadFeedCompletion_readersSuccessfullyLoadedFeed() {
    let image0 = makeImage(description: "a description", location: "a location")
    let image1 = makeImage(description: nil, location: "another location")
    let image2 = makeImage(description: "another description", location: nil)
    let image3 = makeImage(description: nil, location: nil)
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    assertThat(sut, isRending: [])

    loader.completeFeedLoading(with: [image0], at: 0)
    assertThat(sut, isRending: [image0])

    sut.simulateUserInitiatedFeedReload()
    loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
    assertThat(sut, isRending: [image0, image1, image2, image3])
  }

  func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
    let image0 = makeImage()
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeFeedLoading(with: [image0], at: 0)
    assertThat(sut, isRending: [image0])

    sut.simulateUserInitiatedFeedReload()
    loader.completeFeedLoadingWithError(at: 1)
    assertThat(sut, isRending: [image0])
  }

  func test_feedImageView_loadsImageURLWhebVisible() {
    let image0 = makeImage(url: URL(string: "http://url-0.com")!)
    let image1 = makeImage(url: URL(string: "http://url-01.com")!)
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeFeedLoading(with: [image0, image1])

    XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")

    sut.simulateFeedImageViewVisible(at: 0)
    XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first view becomes visible")

    sut.simulateFeedImageViewVisible(at: 1)
    XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second view also becomes visible")
  }

  func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
    let image0 = makeImage(url: URL(string: "http://url-0.com")!)
    let image1 = makeImage(url: URL(string: "http://url-0.com")!)
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeFeedLoading(with: [image0, image1])
    XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")

    sut.simulateFeedImageViewNotVisible(at: 0)
    XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected one cancelled image URL reuqest once first imahe is not visible anymore")

    sut.simulateFeedImageViewNotVisible(at: 1)
    XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected two cancelled image URL requests once second image is also not visible anymore")
  }

  func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeFeedLoading(with: [makeImage(), makeImage()])

    let view0 = sut.simulateFeedImageViewVisible(at: 0)
    let view1 = sut.simulateFeedImageViewVisible(at: 1)

    XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
    XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")

    loader.completeImageLoading(at: 0)
    XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
    XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")

    loader.completeImageLoadingWithError(at: 1)
    XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
    XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
  }

  func test_feedImageView_rendersImageLoadedFromURL() {
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeFeedLoading(with: [makeImage(), makeImage()])

    let view0 = sut.simulateFeedImageViewVisible(at: 0)
    let view1 = sut.simulateFeedImageViewVisible(at: 1)
    XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
    XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")

    let imageData0 = UIImage.make(withColor: .red).pngData()!
    loader.completeImageLoading(with: imageData0, at: 0)
    XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
    XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")

    let imageData1 = UIImage.make(withColor: .blue).pngData()!
    loader.completeImageLoading(with: imageData1, at: 1)
    XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
    XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
  }

  func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeFeedLoading(with: [makeImage(), makeImage()])

    let view0 = sut.simulateFeedImageViewVisible(at: 0)
    let view1 = sut.simulateFeedImageViewVisible(at: 1)
    XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
    XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")

    let imageData = UIImage.make(withColor: .red).pngData()!
    loader.completeImageLoading(with: imageData, at: 0)
    XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
    XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")

    loader.completeImageLoadingWithError(at: 1)
    XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes with error")
    XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error")
  }

  func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeFeedLoading(with: [makeImage()])

    let view = sut.simulateFeedImageViewVisible(at: 0)
    XCTAssertEqual(view?.isShowingRetryAction, false, "Expected no retry action wile loading image")

    let invalidImageData = Data("invalid image data".utf8)
    loader.completeImageLoading(with: invalidImageData, at: 0)
    XCTAssertEqual(view?.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
  }

  func test_feedImageViewRetryAction_retriesImageLoad() {
    let image0 = makeImage(url: URL(string: "http://url-0.com")!)
    let image1 = makeImage(url: URL(string: "http://url-1.com")!)
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeFeedLoading(with: [image0, image1])

    let view0 = sut.simulateFeedImageViewVisible(at: 0)
    let view1 = sut.simulateFeedImageViewVisible(at: 1)
    XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected two image URL request for the two visible views")

    loader.completeImageLoadingWithError(at: 0)
    loader.completeImageLoadingWithError(at: 1)
    XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected only two image URL request before retry action")

    view0?.simulateRetryAction()
    XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url], "Expected third imageURL request after first view retry action")

    view1?.simulateRetryAction()
    XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url], "Expected fourth imageURL request after second view retry action")
  }

  func test_feedImageView_preloadsImageURLWhenNearVisible() {
    let image0 = makeImage(url: URL(string: "http://url-0.com")!)
    let image1 = makeImage(url: URL(string: "http://url-1.com")!)
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeFeedLoading(with: [image0, image1])
    XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")

    sut.simulateFeedImageViewNearVisible(at: 0)
    XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL requset once first image is near visible")

    sut.simulateFeedImageViewNearVisible(at: 1)
    XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request onve second image is near visible")
  }

  func test_feedImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
    let image0 = makeImage(url: URL(string: "http://url-0.com")!)
    let image1 = makeImage(url: URL(string: "http://url-1.com")!)
    let (sut, loader) = makeSUT()

    sut.loadViewIfNeeded()
    loader.completeFeedLoading(with: [image0, image1])
    XCTAssertEqual(loader.loadedImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")

    sut.simulateFeedImageViewNotNearVisible(at: 0)
    XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected first cancelled image URL request once first image is not near visible anymore")

    sut.simulateFeedImageViewNotNearVisible(at: 1)
    XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected second cancelled image url request once second image is not near visible anymore")
  }

  // MARK: - Helpers

  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
    let loader = LoaderSpy()
    let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
    trackForMemoryLeaks(loader, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, loader)
  }

  private func assertThat(_ sut: FeedViewController, isRending feed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
    guard sut.numberOfRenderedFeedImageViews() == feed.count else {
      return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead.", file: file, line: line)
    }

    feed.enumerated().forEach { index, feed in
      assertThat(sut, hasViewConfiguredfor: feed, at: index)
    }
  }

  private func assertThat(_ sut: FeedViewController, hasViewConfiguredfor image: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
    let view = sut.feedImageView(at: index)

    guard let cell = view as? FeedImageCell else {
      return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
    }
    let shouldLocationBeVisible = (image.location != nil)
    XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index (\(index))", file: file, line: line)

    XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing: image.location)) for image view at index (\(index))", file: file, line: line)

    XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at index (\(index))", file: file, line: line)
  }

  private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
    return FeedImage(id: UUID(), description: description, location: location, url: url)
  }

  class LoaderSpy: FeedLoader, FeedImageDataLoader {

    // MARK: - FeedLoader

    private var feedRequests = [(FeedLoader.Result) -> Void]()

    var loadFeedCallCount: Int {
      return feedRequests.count
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      feedRequests.append(completion)
    }

    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
      feedRequests[index](.success(feed))
    }

    func completeFeedLoadingWithError(at index: Int = 0) {
      let error = NSError(domain: "an error", code: 0)
      feedRequests[index](.failure(error))
    }

    // MARK: - FeedImageDataLoader

    private struct TaskSpy: FeedImageDataLoaderTask {
      let cancelCallback: () -> Void

      func cancel() {
        cancelCallback()
      }
    }

    private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

    var loadedImageURLs: [URL] {
      return imageRequests.map { $0.url }
    }
    private(set) var cancelledImageURLs: [URL] = []

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
      imageRequests.append((url, completion))
      return TaskSpy { [weak self] in
        self?.cancelledImageURLs.append(url)
      }
    }

    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
      imageRequests[index].completion(.success(imageData))
    }

    func completeImageLoadingWithError(at index: Int = 0) {
      let error = NSError(domain: "an Error", code: 0)
      imageRequests[index].completion(.failure(error))
    }
  }
}

private extension FeedViewController {
  func simulateUserInitiatedFeedReload() {
    refreshControl?.simulatePullToRefresh()
  }

  @discardableResult
  func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
    return feedImageView(at: index) as? FeedImageCell
  }

  func simulateFeedImageViewNotVisible(at row: Int) {
    let view = simulateFeedImageViewVisible(at: row)
    let delegate = tableView.delegate
    let indexPath = IndexPath(row: row, section: feedImagesSection)
    delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
  }

  func simulateFeedImageViewNearVisible(at row: Int) {
    let dataSource = tableView.prefetchDataSource
    let indexPath = IndexPath(row: row, section: feedImagesSection)
    dataSource?.tableView(tableView, prefetchRowsAt: [indexPath])
  }

  func simulateFeedImageViewNotNearVisible(at row: Int) {
    simulateFeedImageViewVisible(at: row)

    let dataSource = tableView.prefetchDataSource
    let indexPath = IndexPath(row: row, section: feedImagesSection)
    dataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
  }

  var isShowingLoadingIndicator: Bool {
    return refreshControl?.isRefreshing == true
  }

  func numberOfRenderedFeedImageViews() -> Int {
    return tableView.numberOfRows(inSection: feedImagesSection)
  }

  func feedImageView(at row: Int) -> UITableViewCell? {
    let dataSource = tableView.dataSource
    let indexPath = IndexPath(row: row, section: feedImagesSection)
    return dataSource?.tableView(tableView, cellForRowAt: indexPath)
  }

  private var feedImagesSection: Int {
    return 0
  }
}

private extension FeedImageCell {
  func simulateRetryAction() {
    feedImageRetryButton.simulateTap()
  }

  var isShowingLocation: Bool {
    return !locationContainer.isHidden
  }

  var isShowingImageLoadingIndicator: Bool {
    return feedImageContainer.isShimmering
  }

  var isShowingRetryAction: Bool {
    return !feedImageRetryButton.isHidden
  }

  var locationText: String? {
    return locationLabel.text
  }

  var descriptionText: String? {
    return descriptionLabel.text
  }

  var renderedImage: Data? {
    return feedImageView.image?.pngData()
  }
}

private extension UIButton {
  func simulateTap() {
    allTargets.forEach { target in
      actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
        (target as NSObject).perform(Selector($0))
      }
    }
  }
}

private extension UIRefreshControl {
  func simulatePullToRefresh() {
    allTargets.forEach { target in
      actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
        (target as NSObject).perform(Selector($0))
      }
    }
  }
}

private extension UIImage {
  static func make(withColor color: UIColor) -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
    UIGraphicsBeginImageContext(rect.size)
    guard let context = UIGraphicsGetCurrentContext() else {
      fatalError("Get Context failure")
    }
    context.setFillColor(color.cgColor)
    context.fill(rect)
    guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
      fatalError("Not get Image")
    }
    UIGraphicsEndImageContext()
    return image
  }
}

