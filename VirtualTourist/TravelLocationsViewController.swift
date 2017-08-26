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
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
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
        
        setupCoreData()
        
        //Set up Map
        mapView.delegate = self
        longPressGestureRecognizer.minimumPressDuration = 1
        
        //Setup View Elements
        deleteModeLabel = DeleteModeLabel(view: view)
        view.addSubview(deleteModeLabel)
    }
    
    //MARK: Actions
    @IBAction func longPress(_ gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            addPin(at: gestureRecognizer.location(in: mapView))
            
        }
    }
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        
        toggleDeleteMode()
    }
    
}

//MARK: Functions for Edit Button

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
        
        let shiftAmount: CGFloat = 80
        
        if inDeleteMode {
            mapView.frame.origin.y.shift(by: shiftAmount, inDirection: -)
            deleteModeLabel.frame.origin.y.shift(by: shiftAmount, inDirection: -)
        } else {
            mapView.frame.origin.y.shift(by: shiftAmount, inDirection: +)
            deleteModeLabel.frame.origin.y.shift(by: shiftAmount, inDirection: +)
        }
    }
}

//MARK: CoreData Functions

extension TravelLocationsViewController {
    
    func setupCoreData() {
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
    }
    
}

//MARK: Pin Functions

extension TravelLocationsViewController {
    
    func addPin(at touchLocation: CGPoint) {
        let coordinateOnMap = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinateOnMap
        
        if let context = fetchedResultsController?.managedObjectContext {
            let _ = Pin(latitude: annotation.coordinate.latitude,
                        longitude: annotation.coordinate.longitude,
                        context: context)
        }
        
        mapView.addAnnotation(annotation)
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

    
    func deletePin(_ annotation: MKAnnotationView) {
        
        removePinFromStore()
        deleteAnnotation(annotation)
    }
    
    func deleteAnnotation(_ annotation: MKAnnotationView) {
        
        //TODO: Delete annotation from Map
    }
    
    func removePinFromStore() {
        
        //TODO: Remove Pin from Store
    }
}

//MARK: MKMapViewDelegate Functions

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
    
    //Load pins when map finishes rendering
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        
        loadPins()
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        switch inDeleteMode {
        case true:
            
            deletePin(view)
            print("Not in delete mode")
        case false:
            //TODO: Navigate to Tourist Photos
            print("Not in delete mode")
        }
    }
}
