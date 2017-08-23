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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        touristMapView.delegate = self
        
        addPinGestureRecognizer.minimumPressDuration = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TravelLocationsViewController: MKMapViewDelegate {
    
    func addPin(_ gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            let touchPointInView = gestureRecognizer.location(in: touristMapView)
            let coordinateOnMap = touristMapView.convert(touchPointInView, toCoordinateFrom: touristMapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinateOnMap
            
            //TODO: Push coordinates to Pin Model
            
//            touristMapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        //TODO: Set up pin
        return MKAnnotationView()
    }
}

