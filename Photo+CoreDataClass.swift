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
    convenience init(photoUrl url: URL? = nil, context: NSManagedObjectContext) {
        
        let photoData: NSData?
        
        if let url = url {
            photoData = NSData(contentsOf: url)
        } else {
            photoData = nil
        }
        
        if let entity = NSEntityDescription.entity(forEntityName: Constants.EntityNames.Photo,
                                                   in: context) {
            self.init(entity: entity, insertInto: context)
            self.photo = photoData
            self.creationDate = NSDate(timeIntervalSinceNow: 0)
            
        } else {
            fatalError("Unable to create Entity!")
        }
    }

}
