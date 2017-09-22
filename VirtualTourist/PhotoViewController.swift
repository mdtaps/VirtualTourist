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
    var urls = [URL]() {
        didSet {
            if self.urls.isEmpty == false {
                for url in self.urls {
                    let photo = Photo(photoUrl: url, context: fetchedResultsController!.managedObjectContext)
                    photo.pin = pin
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController?.delegate = self
        print(fetchedResultsController?.delegate)
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
            case .Success(let urls, let numberOfPages):
                
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
                self.urls = urls
                
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
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.itemSize = CGSize(width: width / 3, height: width / 3)
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
        
        switch(type) {
        case .insert:
            photosCollectionView.reloadItems(at: [newIndexPath!])
        case .delete:
            photosCollectionView.insertItems(at: [indexPath!])
        case .update:
            photosCollectionView.reloadItems(at: [indexPath!])
        case .move:
            photosCollectionView.deleteItems(at: [indexPath!])
            photosCollectionView.insertItems(at: [newIndexPath!])
        }
    }
}

extension PhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let sections = fetchedResultsController?.sections?.count else {
            print("numberofsections returned zero")
            return 0
        }
        
        print("There are \(sections) sections")
        return sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("About to start numberofitemsinsection")
        guard let sections = fetchedResultsController?.sections else {
            print("The sections in the fetched results controller are: \(fetchedResultsController?.sections)")
            return 0
        }
        
        //TODO: Return number of items on page from Flickr
        return 21
        
//        print("There are \(sections[section].numberOfObjects) objects in section")
//        
//        if sections[section].numberOfObjects >= 21 {
//            return 21
//        } else {
//            return sections[section].numberOfObjects
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //TODO: Display loading wheel
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? PhotoCollectionViewCell else {
            
            //TODO: Show error
            print("We have an error in dequeueing reusable cell")
            return UICollectionViewCell()
        }
        
        print("Cell made")
        
        if fetchedResultsController?.fetchedObjects?.isEmpty == false {
            print("Returned true")
            guard let entity = fetchedResultsController?.object(at: indexPath) as? Photo,
                  let data = entity.photo else {
                fatalError("No fetchedResultsController set in collection view cellforitemat indexpath")
            }
            
            print("About to print data")
            
            cell.imageView.image = UIImage(data: data as Data)
        } else {
            cell.backgroundColor = .black

        }
        
        return cell
    }
}
