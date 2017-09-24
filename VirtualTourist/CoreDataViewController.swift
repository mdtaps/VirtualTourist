//
//  CoreDataViewController.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 8/28/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import UIKit
import CoreData

class CoreDataViewController: UIViewController {
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        
        didSet {
            if let fc = fetchedResultsController {
                
                do {
                    try fc.performFetch()
                } catch let e as NSError {
                    print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
                }
            }
        }
    }
    
    func createFetchedResultsController(for managedObject: NSManagedObject.Type, sortingBy descriptor: String? = nil) -> NSFetchedResultsController<NSFetchRequestResult> {
        
        //Create fetch request
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = managedObject.fetchRequest()
        
        //Add sort descriptors
        var descriptors = [NSSortDescriptor]()
        
        for attribute in managedObject.entity().attributesByName {
            
            if descriptor == attribute.key {
                
                descriptors.append(NSSortDescriptor(key: attribute.key, ascending: true))
            } else {
                descriptors.append(NSSortDescriptor(key: attribute.key, ascending: false))
            }
        }
        
        fetchRequest.sortDescriptors = descriptors
        
        //Return fetchedresultsController
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
    }
}
