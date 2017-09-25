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
    
    var pin: Pin?
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    var currentPage = 0
    var numberOfPages: Int = 1
    var blockOperation: [BlockOperation] = []
    var hasPhotos = false
    var perPage: Int? {
        didSet {
            photosCollectionView.reloadData()
        }
    }

    
    var urls = [URL]() {
        didSet {
            
            DispatchQueue.main.async {
                self.delegate.stack.performBackgroundBatchOperation { (workerContext) in
                    let pinId = self.pin?.objectID
                    
                    do {
                        let myPin = try workerContext.existingObject(with: pinId!) as? Pin
                        
                        for url in self.urls {
                            let photo = Photo(photoUrl: url, context: workerContext)
                            photo.pin = myPin
                            
                        }
                    } catch let e as NSError {
                        print("There was an error: \(e.localizedDescription)")
                    }
                    
                    self.hasPhotos = true
                    
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController?.delegate = self
        loadPhotos()
        setupCollectionView()

    }

     func loadPhotos() {
        
        if let objects = fetchedResultsController?.fetchedObjects, objects.isEmpty != true {
            
            print("We have pictures in the store!")
        }
        //TODO: Check for photos already loaded
        
        currentPage += 1
        
        if currentPage > numberOfPages {
            currentPage = 1
        }
        
        FlickrClient.shared.retrieve(picturesFor: pin, picturesAt: currentPage) { (response) in
            switch response {
            case .Failure(let errorMessage):
                print(errorMessage)
            //TODO: Display error
            case .Success(let urls, let numberOfPages, let perPage):
                
                if urls.isEmpty {
                    print("No Pictures Found")
                    //TODO: Display No Pictures Found message
                }
                
                guard let context = self.fetchedResultsController?.managedObjectContext else {
                    //TODO: Display error
                    print("Failed to get context")
                    return
                }
                
                self.numberOfPages = numberOfPages
                DispatchQueue.main.async {
                    self.perPage = perPage
                    self.urls = urls
                }
                
                do {
                    try self.fetchedResultsController?.performFetch()
                } catch {
                    print(error)
                }
                //TODO: Get photo asyncronously
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
    }
}

extension PhotoViewController: NSFetchedResultsControllerDelegate {
        
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        
        switch (type) {
        case .insert:
            photosCollectionView.insertSections(set)
        case .delete:
            photosCollectionView.deleteSections(set)
        default:
            // irrelevant in our case
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            photosCollectionView.reloadData()
        case .delete:
            photosCollectionView.deleteItems(at: [indexPath!])
        case .update:
            photosCollectionView.reloadItems(at: [indexPath!])
        case .move:
            photosCollectionView.deleteItems(at: [indexPath!])
            photosCollectionView.insertItems(at: [newIndexPath!])
        }
            
//        case .insert:
//            let operation = BlockOperation(block: { 
//                self.photosCollectionView.insertItems(at: [newIndexPath!])
//            })
//            blockOperation.append(operation)
//        case .delete:
//            let operation = BlockOperation(block: {
//                self.photosCollectionView.insertItems(at: [newIndexPath!])
//            })
//            blockOperation.append(operation)
//        }
    }
}

extension PhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let sections = fetchedResultsController?.sections?.count else {
            print("numberofsections returned zero")
            return 0
        }
        
        print("There are \(sections) sections")
        return sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let perPage = perPage else {
            return 0
        }
        
        if perPage == 0 {
            return 0
            //TODO: Display "No data"
        } else {
            return perPage
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //TODO: Display loading wheel
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? PhotoCollectionViewCell else {
            
            //TODO: Show error
            print("We have an error in dequeueing reusable cell")
            return UICollectionViewCell()
        }
        
        if hasPhotos {
            guard let photo = fetchedResultsController?.object(at: indexPath) as? Photo else {
                fatalError("Could not get photo from fetched results contrtoller at \(indexPath)")
            }
            
            cell.imageView.image = UIImage(data: photo.photo! as Data)
            
        } else {
            cell.backgroundView = PhotoActivityIndicator().getActivityIndicator()
        }
        
        return cell
    }
}
