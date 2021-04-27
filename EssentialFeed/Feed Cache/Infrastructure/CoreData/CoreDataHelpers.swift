//
//  CoreDataHelpers.swift
//  EssentialFeed
//
//  Created by Min on 2021/4/27.
//  Copyright © 2021 Min. All rights reserved.
//

import CoreData

extension NSPersistentContainer {
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

extension NSManagedObjectModel {
  static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
    return bundle
      .url(forResource: name, withExtension: "momd")
      .flatMap { NSManagedObjectModel(contentsOf: $0) }
  }
}
