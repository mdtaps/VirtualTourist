//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 9/24/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var photo: NSData?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var pin: Pin?

}
