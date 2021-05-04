//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Min on 2021/4/27.
//  Copyright © 2021 Min. All rights reserved.
//

import CoreData


//@objc(ManagedFeedImage)
//private class ManagedFeedImage: NSManagedObject {
//  @NSManaged var id: UUID
//  @NSManaged var imageDescription: String?
//  @NSManaged var location: String?
//  @NSManaged var url: URL
//  @NSManaged var cache: ManagedCache
//}

 extension ManagedFeedImage {

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
