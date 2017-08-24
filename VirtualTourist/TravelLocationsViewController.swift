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
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var addPinGestureRecognizer: UILongPressGestureRecognizer!
    
    //Propeties
    var deleteModeLabel = DeleteModeLabel()
    var inDeleteMode = false
    
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
        mapView.delegate = self
        addPinGestureRecognizer.minimumPressDuration = 1
        
        //Create label for alerting to delete mode
        deleteModeLabel = DeleteModeLabel(view: view)
        view.addSubview(deleteModeLabel)
    }
    
    @IBAction func addPin(_ gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            let touchPointInView = gestureRecognizer.location(in: mapView)
            let coordinateOnMap = mapView.convert(touchPointInView, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinateOnMap
            
            if let context = fetchedResultsController?.managedObjectContext {
                let _ = Pin(latitude: annotation.coordinate.latitude,
                              longitude: annotation.coordinate.longitude,
                              context: context)
            }
            
            mapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        
        toggleDeleteMode()
    }
    
    func loadPins() {
        var pins = [(Double, Double)]()
        
        let request = NSFetchRequest<Pin>(entityName: Constants.EntityNames.Pin)
        
        do {
            guard let entities = try fetchedResultsController?.managedObjectContext.fetch(request) else {
                throw NSError(domain: "loadPins", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to load entities"])
            }
            
            for entity in entities {
                pins.append((entity.latitude, entity.longitude))
            }
        } catch let error as NSError {
            dump(error)
        }
        
        dropPins(arrayOf: pins)
    }
    
    func dropPins(arrayOf pinCoordinates: [(Double, Double)]) {
        
        for coordinates in pinCoordinates {
            
            let (lat, lon) = coordinates
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            mapView.addAnnotation(annotation)
        }
    }
}

extension TravelLocationsViewController {
    
    func toggleDeleteMode() {
        
        inDeleteMode = !inDeleteMode
        
        setupMapGestures()
        setupView()
    }
    
    func setupMapGestures() {
        
        guard let recognizers = mapView.gestureRecognizers else {
            print("Error finding gesture recognizers in tourist map view")
            return
        }
        
        for recognizer in recognizers {
            
            if recognizer is UILongPressGestureRecognizer {
                
                recognizer.isEnabled = !inDeleteMode
            }
        }
    }
    
    func setupView() {
        
        let DeleteModeBarHeight: CGFloat = 80
        
        if inDeleteMode {
            mapView.frame.origin.y -= DeleteModeBarHeight
            deleteModeLabel.frame.origin.y -= DeleteModeBarHeight
        } else {
            mapView.frame.origin.y += DeleteModeBarHeight
            deleteModeLabel.frame.origin.y -= DeleteModeBarHeight

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
        return pinObject
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        
        loadPins()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard inDeleteMode else {
            return
        }
        
        //TODO: Delete pin and remove from context
    }
}
