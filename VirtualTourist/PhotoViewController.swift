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
    var currentPage = 0
    var numberOfPages: Int = 1
    var blockOperation: [BlockOperation] = []
    var hasPhotos = false
    var perPage: Int? {
        didSet {
            DispatchQueue.main.async {
                self.photosCollectionView.reloadData()
            }
        }
    }
    
    var urls = [URL]() {
        didSet {
            self.delegate.stack.performBackgroundBatchOperation { (workerContext) in
                let pinId = self.pin?.objectID
                
                let myPin = workerContext.object(with: pinId!) as? Pin
                
                for url in self.urls {
                    let photo = Photo(photoUrl: url, context: workerContext)
                    photo.pin = myPin
                    
                }
                self.hasPhotos = true
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController?.delegate = self
        photosMapView.delegate = self
        
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
                    self.perPage = 0
                    return
                    //TODO: Display No Pictures Found message
                }
                
                self.numberOfPages = numberOfPages
                self.perPage = perPage
                
                print("perPage is \(perPage)")
                
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
            photosCollectionView.reloadItems(at: [newIndexPath!])
        case .delete:
            photosCollectionView.deleteItems(at: [indexPath!])
        case .update:
            photosCollectionView.reloadItems(at: [indexPath!])
        case .move:
            photosCollectionView.deleteItems(at: [indexPath!])
            photosCollectionView.insertItems(at: [newIndexPath!])
        }
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
        
        print(perPage)
        
        if perPage == 0 {
            collectionViewLabel.isHidden = false
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

extension PhotoViewController: MKMapViewDelegate {
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        guard let pin = pin else {
            fatalError("No pin set for viewDidLoad")
        }
        
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegion(center: pin.coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        
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
