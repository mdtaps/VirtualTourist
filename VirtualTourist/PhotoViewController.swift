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
    
    var pin: Pin?
    var model = PhotoDataModel()
    var mapModel: PhotoMapModel?
    
    var itemsToReload = [IndexPath]()
    var itemsToDelete = [IndexPath]()
    var itemsToUpdate = [IndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController?.delegate = self
        mapModel = PhotoMapModel(pin)
        photosMapView.delegate = mapModel
        setupCollectionView()
        
        if let count = fetchedResultsController?.fetchedObjects?.count, count > 0 {
            print("Items in context at beginning is \(count)")
            model.numberOfItemsInCollectionView = count
            photosCollectionView.reloadData()
        } else {
            loadPhotos {
                self.createPhotoItems()

            }
        }
    }
    
    @IBAction func reloadPhotos() {
        loadPhotos {
            self.createPhotoItems()

        }
    }
    
    func createPhotoItems() {
        photosCollectionView.reloadData()
        
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
                    //TODO: Display No Pictures Found message
                }
                this.model.numberOfItemsInCollectionView = urls.count
                this.model.numberOfPages = numberOfPages
                this.model.urls = urls
                
                completionHandlerForLoadPhotos()
            }
        }
    }
    
    func setupCollectionView() {
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.itemSize = CGSize(width: width / 3 - 10, height: width / 3 - 10)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        photosCollectionView.collectionViewLayout = layout
        
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
    
    //When changes are finished, batch perform updates for CollectionView
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        photosCollectionView.performBatchUpdates({ 
            for indexPath in self.itemsToReload {
                self.photosCollectionView.reloadItems(at: [indexPath])
            }
            
            for indexPath in self.itemsToDelete {
                print("Delete called")
                self.photosCollectionView.deleteItems(at: [indexPath])
                
            }
            
            self.model.numberOfItemsInCollectionView -= self.itemsToDelete.count
        
            for indexPath in self.itemsToUpdate {
                self.photosCollectionView.reloadItems(at: [indexPath])
            }

        }, completion: { (_) in
            self.photosCollectionView.reloadData()
        })
    }
}

extension PhotoViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("Number of items in section called, there are \(model.numberOfItemsInCollectionView)")
        
        return model.numberOfItemsInCollectionView
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //TODO: Display loading wheel
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? PhotoCollectionViewCell else {
            
            //TODO: Show error
            print("We have an error in dequeueing reusable cell")
            return UICollectionViewCell()
        }
        
        if (fetchedResultsController?.sections?[0].numberOfObjects)! > indexPath.item {
            guard let photo = fetchedResultsController?.object(at: indexPath) as? Photo else {
                fatalError("Could not get photo from fetched results contrtoller at \(indexPath)")
            }
            
            if let data = photo.photo as Data? {
                cell.imageView.image = UIImage(data: data)
                cell.backgroundView = nil
                
                dump(model.itemsSelectedToDelete)
                
                if model.itemsSelectedToDelete.contains(indexPath) {
                    cell.imageView.alpha = 0.25
                    
                } else {
                    cell.imageView.alpha = 1
                    
                }
                
            } else {
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
        if model.itemsSelectedToDelete.contains(indexPath) {
            model.itemsSelectedToDelete = model.itemsSelectedToDelete.filter { $0 != indexPath }
            
        } else {
            model.itemsSelectedToDelete.append(indexPath)
            
        }
        
        photosCollectionView.reloadItems(at: [indexPath])
    }
    
}

extension PhotoViewController: MKMapViewDelegate {
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        guard let pin = pin else {
            fatalError("No pin set for viewDidLoad")
        }
        
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegion(center: pin.coordinate, span: span)
        
        mapView.setRegion(region, animated: false)
        
        mapView.addAnnotation(pin)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinObject = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinObject == nil {
            pinObject = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinObject?.canShowCallout = false
            pinObject?.animatesDrop = false
            pinObject?.tintColor = .red
        } else {
            pinObject?.annotation = annotation
        }
        return pinObject
    }
}
