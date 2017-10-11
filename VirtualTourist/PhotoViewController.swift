//
//  PhotoViewController.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 9/6/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import UIKit
import CoreData
import MapKit

//TODO: Setup Flickr request URL to take page number paramenter
//TODO: If page number is greater than number of pages,
//      restart the page

class PhotoViewController: CoreDataViewController {
    
    @IBOutlet weak var photosMapView: MKMapView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewLabel: UILabel!
    @IBOutlet weak var collectionViewButton: UIButton!
    
    //MARK: Properties
    var pin: Pin?
    var model = PhotoDataModel()
    var mapModel: PhotoMapModel?
    
    //Arrays for holding indexPath of items to make changes
    //on in FetchedResultsController delegate functions. Code from
    //ColorCollection app found in Udacity Forums
    var itemsToReload = [IndexPath]()
    var itemsToDelete = [IndexPath]()
    var itemsToUpdate = [IndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController?.delegate = self
        mapModel = PhotoMapModel(pin)
        photosMapView.delegate = mapModel
        
        collectionViewButton.titleLabel?.text = "New Collection"
        setupCollectionView()
        
        //If the FRC has objects, reload the collection view
        if let count = fetchedResultsController?.fetchedObjects?.count, count > 0 {
            model.numberOfItemsInCollectionView = count
            photosCollectionView.reloadData()
            
        //If the FRC has no objects, load photos from Flickr
        } else {
            reloadPhotos()
        }
    }
    
    @IBAction func buttonPressed() {
        
        switch model.buttonMode {
            
        //If button is in reload mode, reload items
        case .ReloadItems:
            reloadPhotos()
        
        //If button is in delete mode, remove all the items that have been selected
        case .DeleteItems:
            model.removeSelectedPhotos(fetchedResultsController: fetchedResultsController)
            updateButtonMode()
        }
    }
    
    //Photo entities are created after the urls are returned from Flickr
    func reloadPhotos() {
        loadPhotos {
            self.createPhotoItems()
            
        }
    }

    
    func loadPhotos(completionHandlerForLoadPhotos: @escaping () -> () ) {
        
        model.prepareForRetrievingPhotos(fetchedResultsController: fetchedResultsController)
        
        FlickrClient.shared.retrieve(picturesFor: pin, picturesAt: model.currentPage) { [weak self] (response) in
            
            guard let this = self else {
                print("No PhotoViewController set")
                return
                
            }
            
            switch response {
            case .Failure(let errorMessage):
                print(errorMessage)
            //TODO: Display error
            case .Success(let urls, let numberOfPages, _):
                
                if urls.isEmpty {
                    this.collectionViewLabel.isHidden = false
                    return
                }
                
                this.model.numberOfItemsInCollectionView = urls.count
                this.model.numberOfPages = numberOfPages
                this.model.urls = urls
                
                completionHandlerForLoadPhotos()
            }
        }
    }
    
    func createPhotoItems() {
        DispatchQueue.main.async {
            self.photosCollectionView.reloadData()
            
        }
        
        guard let pinId = pin?.objectID else {
            print("No pin found while retreiving pictures")
            return
        }
        
        let backgroundPin = delegate.stack.backgroundContext.object(with: pinId) as? Pin
        
        for url in self.model.urls {
            delegate.stack.performBackgroundBatchOperation { (workerContext) in
                let photo = Photo(photoUrl: url, context: workerContext)
                photo.pin = backgroundPin
            }
            
        }
        
    }
    
    private func setupCollectionView() {
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        photosCollectionView.setupPhotoCollectionView()
        collectionViewLabel.isHidden = true
    }
}

extension PhotoViewController: NSFetchedResultsControllerDelegate {
    
    //Refresh arrays that hold index paths of changed items
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        itemsToReload = [IndexPath]()
        itemsToDelete = [IndexPath]()
        itemsToUpdate = [IndexPath]()
    }
    
    //Add index paths to array for corresponding change type
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            itemsToReload.append(newIndexPath!)
        case .delete:
            itemsToDelete.append(indexPath!)
        case .update:
            itemsToUpdate.append(indexPath!)
        case .move:
            print("A move shouldn't have happened...")
            break
        }
    }
    
    //When changes are finished, batch perform updates for CollectionView. Code from
    //ColorCollection project on Udacity forums
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        photosCollectionView.performBatchUpdates({ 
            for indexPath in self.itemsToReload {
                self.photosCollectionView.reloadItems(at: [indexPath])
            }
            
            for indexPath in self.itemsToDelete {
                self.photosCollectionView.deleteItems(at: [indexPath])
                
            }
            
            self.model.numberOfItemsInCollectionView -= self.itemsToDelete.count
        
            for indexPath in self.itemsToUpdate {
                self.photosCollectionView.reloadItems(at: [indexPath])
            }

        }, completion: { (_) in
            self.photosCollectionView.reloadData()
            self.delegate.stack.save()
        })
    }
}

extension PhotoViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return model.numberOfItemsInCollectionView
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? PhotoCollectionViewCell else {
            print("We have an error in dequeueing reusable cell")
            return UICollectionViewCell()
        }
        
        //Only try to load data if the number of items in FRC greater than the item number
        //If there are fewer items, show a loading wheel
        if (fetchedResultsController?.sections?[0].numberOfObjects)! > indexPath.item {
            guard let photo = fetchedResultsController?.object(at: indexPath) as? Photo else {
                print("Could not get photo in cellForItemAt indexPath")
                return cell
            }
            
            //If the photo at the correct indexPath has data, use that data to load photo and stop wheel
            if let data = photo.photo as Data? {
                cell.imageView.image = UIImage(data: data)
                cell.backgroundView = nil
                
                //If the item is selected to delete, set add transparency to image
                if model.indexPathsOfItemsSelectedToDelete.contains(indexPath) {
                    cell.imageView.alpha = 0.25
                    
                } else {
                    cell.imageView.alpha = 1
                    
                }
                
            } else {
                //If no data
                cell.backgroundView = PhotoActivityIndicator().getActivityIndicator()
            }
            
        } else {
            cell.backgroundView = PhotoActivityIndicator().getActivityIndicator()
        }
        
        return cell

    }
    
}

extension PhotoViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //When cell selected, if indexPath is contained in itemsSelectedToDelete,
        //remove that indexPath. Otherwise, add the indexPath
        if model.indexPathsOfItemsSelectedToDelete.contains(indexPath) {
            model.indexPathsOfItemsSelectedToDelete = model.indexPathsOfItemsSelectedToDelete.filter { $0 != indexPath }
            
        } else {
            model.indexPathsOfItemsSelectedToDelete.append(indexPath)
            
        }
        
        //Function to update button view
        updateButtonMode()
        
        photosCollectionView.reloadItems(at: [indexPath])
    }
    
    fileprivate func updateButtonMode() {
        
        if model.indexPathsOfItemsSelectedToDelete.isEmpty {
            model.buttonMode = .ReloadItems
            
        } else {
            model.buttonMode = .DeleteItems
            
        }
        
        collectionViewButton.setTitle(model.buttonMode.rawValue, for: .normal)
    }
    
}
