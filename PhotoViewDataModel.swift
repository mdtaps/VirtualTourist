//
//  PhotoDataModel.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 10/5/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import Foundation
import CoreData

class PhotoDataModel {
    
    var currentPage = 0
    var numberOfPages = 1
    var urls = [URL]()
    var numberOfItemsInCollectionView = 0
    
    func prepareForRetrievingPhotos(fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?) {
        guard let fetchedResultsController = fetchedResultsController else {
            print("No FRC set in loadPhotos")
            return
        }
        
        clearData(of: fetchedResultsController)
        setCurrentPage()
        
    }
    
    func clearData(of fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>) {
                
        if let objects = fetchedResultsController.fetchedObjects as? [NSManagedObject] {
            fetchedResultsController.managedObjectContext.performAndWait {
                for object in objects {
                    fetchedResultsController.managedObjectContext.delete(object)
                    
                }
                
            }
            
            
        }
        
    }
    
    func setCurrentPage() {
        currentPage += 1
        
        if currentPage > numberOfPages {
            currentPage = 1
        }

    }
    
}
