//
//  PhotoMapModel.swift
//  VirtualTourist
//
//  Created by Mark Tapia on 10/6/17.
//  Copyright © 2017 Mark Tapia. All rights reserved.
//

import Foundation
import MapKit

class PhotoMapModel: NSObject, MKMapViewDelegate {
    
    var pin: Pin?
    
    init(_ pin: Pin?) {
        self.pin = pin
    }
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
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
