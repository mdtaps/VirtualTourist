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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchedResultsController?.delegate = self
        loadPhotos()
        setupCollectionView()
    }

     func loadPhotos() {
        
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
                    //TODO: Display No Pictures Found message
                }
                
                guard let context = self.fetchedResultsController?.managedObjectContext else {
                    //TODO: Display error
                    print("Failed to get context")
                    return
                }
                
                self.numberOfPages = numberOfPages
                
                for url in urls {
                    let _ = Photo(photoUrl: url, context: context)
                }
                
                DispatchQueue.main.async {
                    self.photosCollectionView.reloadData()
                }
                
                //TODO: Get photo asyncronously
            }
        }
    }
    
    func setupCollectionView() {
        photosCollectionView.delegate = self
        
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
    //TODO: Setup cell reload when Photo added

}

extension PhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let sections = fetchedResultsController?.sections?.count else {
            return 0
        }
        
        return sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let sections = fetchedResultsController?.sections else {
            return 0
        }
        
        if sections[section].numberOfObjects > 21 {
            return 21
        } else {
            return sections[section].numberOfObjects
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //TODO: Display loading wheel
        
        guard let cell = photosCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? PhotoCollectionViewCell else {
            
            //TODO: Show error
            return UICollectionViewCell()
        }
        
        guard let entity = fetchedResultsController?.object(at: indexPath) as? Photo,
              let data = entity.photo else {
            fatalError("No fetchedResultsController set in collection view cellforitemat indexpath")
        }
        
        cell.imageView.image = UIImage(data: data as Data)
        
        return cell
    }
}
