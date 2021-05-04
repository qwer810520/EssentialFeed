//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Min on 2021/3/3.
//  Copyright © 2021 Min. All rights reserved.
//

import Foundation

 struct RemoteFeedItem: Decodable {
   let id: UUID
   let description: String?
   let location: String?
   let image: URL
}
