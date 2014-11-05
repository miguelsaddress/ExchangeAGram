//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Miguel Angel Moreno Armenteros on 05/11/14.
//  Copyright (c) 2014 Miguel Angel Moreno Armenteros. All rights reserved.
//

import Foundation
import CoreData

@objc(FeedItem)
class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData

}
