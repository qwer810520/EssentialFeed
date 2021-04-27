//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Min on 2021/4/27.
//  Copyright © 2021 Min. All rights reserved.
//

import CoreData

//@objc(ManagedCache)
//private class ManagedCache: NSManagedObject {
//  @NSManaged var timestamp: Date
//  @NSManaged var feed: NSOrderedSet
//}

internal extension ManagedCache {

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
