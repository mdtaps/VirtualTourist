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
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        
        didSet {
            
            if let delegate = self as? NSFetchedResultsControllerDelegate {
                fetchedResultsController?.delegate = delegate
            }
            
            do {
                try fetchedResultsController?.performFetch()
            } catch let error as NSError {
                print("Error while trying to perform search: \n \(error)")
            }
        }
    }
    
    func createFetchedResultsController(for managedObject: NSManagedObject.Type, sortingBy descriptor: String? = nil) -> NSFetchedResultsController<NSFetchRequestResult> {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        guard let stack = delegate.stack else {
            
            fatalError("Could not refrence stack in Travel Locations VC")
        }
        
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
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
    }
}
