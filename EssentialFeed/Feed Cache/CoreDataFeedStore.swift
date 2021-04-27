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
  private var context: NSManagedObjectContext

  public init(storeURL: URL, bundle: Bundle = .main) throws {
    container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
    context = container.newBackgroundContext()
  }

  public func retrieve(completion: @escaping RetrievalCompletion) {
    let context = self.context
    context.perform {
      do {
        if let cache = try ManagedCache.find(in: context) {
          completion(.found(feed: cache.localFeed,
                            timestamp: cache.timestamp!))
        } else {
          completion(.empty)
        }
      } catch {
        completion(.failure(error))
      }
    }
  }

  public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    let context = self.context
    context.perform {
      do {
        let managedCache = try ManagedCache.newUniqueInstance(in: context)
        managedCache.timestamp = timestamp
        managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
        try context.save()
        completion(nil)
      } catch {
        completion(error)
      }
    }
  }

  public func deletecachedFeed(completion: @escaping DeletionCompletion) {
    let context = self.context
    context.perform {
      do {
        try ManagedCache.find(in: context).map(context.delete).map(context.save)
        completion(nil)
      } catch {
        completion(error)
      }
    }
  }
}

private extension NSPersistentContainer {
  enum LoadingError: Swift.Error {
    case modelNotFound
    case failedToLoadPersistentStores(Swift.Error)
  }

  static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
    guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
      throw LoadingError.modelNotFound
    }

    let description = NSPersistentStoreDescription(url: url)
    let container = NSPersistentContainer(name: name, managedObjectModel: model)
    container.persistentStoreDescriptions = [description]
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

private extension ManagedCache {

  static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
    let request = NSFetchRequest<ManagedCache>(entityName: entity().name ?? "")
    request.returnsObjectsAsFaults = false
    return try context.fetch(request).first
  }

  static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
    try find(in: context).map(context.delete)
    return ManagedCache(context: context)
  }

  var localFeed: [LocalFeedImage] {
    guard let feed = feed else {
      fatalError("Not find Feed List")
    }
    return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
  }
}

private extension ManagedFeedImage {

  static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
    return NSOrderedSet(array: localFeed.map{ local in
      let managed = ManagedFeedImage(context: context)
      managed.id = local.id
      managed.imageDescription = local.description
      managed.location = local.location
      managed.url = local.url
      return managed
    })
  }

  var local: LocalFeedImage {
    guard let id = id, let url = url else {
      fatalError("Not find id or url")
    }
    return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
  }
}

//@objc(ManagedCache)
//private class ManagedCache: NSManagedObject {
//  @NSManaged var timestamp: Date
//  @NSManaged var feed: NSOrderedSet
//}
//
//@objc(ManagedFeedImage)
//private class ManagedFeedImage: NSManagedObject {
//  @NSManaged var id: UUID
//  @NSManaged var imageDescription: String?
//  @NSManaged var location: String?
//  @NSManaged var url: URL
//  @NSManaged var cache: ManagedCache
//}


