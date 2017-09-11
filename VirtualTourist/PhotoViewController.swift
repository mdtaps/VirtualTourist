//
//  PhotoViewController.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 9/6/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import UIKit

class PhotoViewController: CoreDataViewController {
    
    var pin: Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let pin = pin {
            FlickrClient.shared.retrieve(picturesFor: pin) { (response) in
                
                switch response {
                case .Failure(let errorMessage):
                    print(errorMessage)
                    //TODO: Display error
                case .Success(let urls):
                    
                    //TODO: Set up Photos in core data correctly
                    for url in urls {
                        let _ = Photo(photoUrl: url, context: (self.fetchedResultsController?.managedObjectContext)!)
                    }
                    
                }
            }

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
