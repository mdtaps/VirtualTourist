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
    var indexPathsOfItemsSelectedToDelete = [IndexPath]()
    var buttonMode = ButtonMode.ReloadItems
    
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
    
    func removeSelectedPhotos(fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?) {
        guard let fetchedResultsController = fetchedResultsController else {
            print("FRC not set in PhotoViewDataModel removePhotos")
            return
            
        }
        
        for indexPath in indexPathsOfItemsSelectedToDelete {
            guard let object = fetchedResultsController.object(at: indexPath) as? NSManagedObject else {
                print("No valid object at \(indexPath) in removePhotos")
                continue
                
            }
            
            fetchedResultsController.managedObjectContext.delete(object)
            
        }
        
        indexPathsOfItemsSelectedToDelete.removeAll(keepingCapacity: false)
        
    }
        
    private func setCurrentPage() {
        currentPage += 1
        
        if currentPage > numberOfPages {
            currentPage = 1
        }

    }
    
}

enum ButtonMode: String {
    case DeleteItems = "Delete Selected Items"
    case ReloadItems = "New Collection"
}
