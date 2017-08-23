//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 8/21/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController {

    @IBOutlet weak var touristMapView: MKMapView!
    @IBOutlet var addPinGestureRecognizer: UILongPressGestureRecognizer!
    
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
        
        //Set up CoreData stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        guard let stack = delegate.stack else {
            fatalError("Could not refrence stack in Travel Locations VC")
        }
        
        //Set up Core Data
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.EntityNames.Pin)
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Constants.PinAttributeNames.Latitude, ascending: false),
                                        NSSortDescriptor(key: Constants.PinAttributeNames.Longitude, ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: stack.context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        
        //Set up Map
        touristMapView.delegate = self
        addPinGestureRecognizer.minimumPressDuration = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addPin(_ gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            let touchPointInView = gestureRecognizer.location(in: touristMapView)
            let coordinateOnMap = touristMapView.convert(touchPointInView, toCoordinateFrom: touristMapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinateOnMap
            
            if let context = fetchedResultsController?.managedObjectContext {
                let pin = Pin(latitude: annotation.coordinate.latitude,
                              longitude: annotation.coordinate.longitude,
                              context: context)
            }
            
            touristMapView.addAnnotation(annotation)
        }
    }
}

extension TravelLocationsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinObject = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinObject == nil {
            pinObject = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinObject?.canShowCallout = false
            pinObject?.animatesDrop = true
            pinObject?.tintColor = .red
        } else {
            pinObject?.annotation = annotation
        }
        //TODO: Set up pin
        return pinObject
    }
}
