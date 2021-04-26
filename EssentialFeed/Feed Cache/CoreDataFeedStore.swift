//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Min on 2021/4/26.
//  Copyright © 2021 Min. All rights reserved.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {

  private let container: NSPersistentContainer

  public init(bundle: Bundle = .main) throws {
    container = try NSPersistentContainer.load(modelName: "FeedStore", in: bundle)
  }

  public func retrieve(completion: @escaping RetrievalCompletion) {
    completion(.empty)
  }

  public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {

  }

  public func deletecachedFeed(completion: @escaping DeletionCompletion) {

  }
}

private extension NSPersistentContainer {
  enum LoadingError: Swift.Error {
    case modelNotFound
    case failedToLoadPersistentStores(Swift.Error)
  }

  static func load(modelName name: String, in bundle: Bundle) throws -> NSPersistentContainer {
    guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
      throw LoadingError.modelNotFound
    }

    let container = NSPersistentContainer(name: name, managedObjectModel: model)
    var loadError: Swift.Error? = nil
    container.loadPersistentStores { loadError = $1 }
    if let error = loadError {
      throw LoadingError.failedToLoadPersistentStores(error)
    } else {
      return container
    }
  }
}

private extension NSManagedObjectModel {
  static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
    return bundle
      .url(forResource: name, withExtension: "momd")
      .flatMap { NSManagedObjectModel(contentsOf: $0) }
  }
}

//@objc(ManagedFeedImage)
//internal class ManagedCache: NSManagedObject {
//  @NSManaged internal var timestamp: Date
//  @NSManaged internal var feed: NSOrderedSet
//}
//
//@objc(ManagedCache)
//internal class ManagedFeedImage: NSManagedObject {
//  @NSManaged internal var id: UUID
//  @NSManaged internal var imageDescription: String?
//  @NSManaged internal var location: String?
//  @NSManaged internal var url: URL
//  @NSManaged internal var cache: ManagedCache
//}


