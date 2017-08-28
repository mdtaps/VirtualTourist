//
//  CoreDataViewController.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 8/28/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import UIKit
import CoreData

class CoreDataViewController: UIViewController {

    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            do {
                try fetchedResultsController?.performFetch()
            } catch let error as NSError {
                print("Error while trying to perform search: \n \(error)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
