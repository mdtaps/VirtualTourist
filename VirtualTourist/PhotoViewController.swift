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

class PhotoViewController: CoreDataViewController {
    
    var pin: Pin?
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadPhotos()
        setupCollectionView()
    }

     func loadPhotos() {
        
        //TODO: Check for photos already loaded
        
        FlickrClient.shared.retrieve(picturesFor: pin) { (response) in
            switch response {
            case .Failure(let errorMessage):
                print(errorMessage)
            //TODO: Display error
            case .Success(let urls):
                guard let context = self.fetchedResultsController?.managedObjectContext else {
                    //TODO: Display error
                    print("Failed to get context")
                    return
                }
                
                for url in urls {
                    let _ = Photo(photoUrl: url, context: context)
                }
            }
        }
    }
    
    func setupCollectionView() {
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
    
}

extension PhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = photosCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    }
}
