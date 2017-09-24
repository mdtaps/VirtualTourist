//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 9/24/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    convenience init(photoUrl url: URL, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entity(forEntityName: Constants.EntityNames.Photo,
                                                   in: context),
            let photo = NSData(contentsOf: url) {
            self.init(entity: entity, insertInto: context)
            self.photo = photo
            self.creationDate = NSDate(timeIntervalSinceNow: 0)
            
        } else {
            fatalError("Unable to create Entity!")
        }
    }

}
