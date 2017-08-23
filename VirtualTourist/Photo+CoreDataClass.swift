//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 8/21/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    convenience init(photoData photo: NSData, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entity(forEntityName: Constants.EntityNames.Photo,
                                                   in: context) {
            self.init(entity: entity, insertInto: context)
            self.photo = photo
            
        } else {
            fatalError("Unable to create Entity!")
        }
    }
}
