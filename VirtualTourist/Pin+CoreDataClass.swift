//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 8/21/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        //Create entity to give Pin class access to its entities in Database
        if let entity = NSEntityDescription.entity(forEntityName: Constants.EntityNames.Pin, in: context) {
            self.init(entity: entity, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            
        } else {
            fatalError("Unable to find entity name!")
            
        }
    }
}
