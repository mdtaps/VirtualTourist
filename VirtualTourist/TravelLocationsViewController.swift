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

class TravelLocationsViewController: CoreDataViewController {
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    //Propeties
    var deleteModeLabel = DeleteModeLabel()
    var inDeleteMode = false
    final let ShiftAmount: CGFloat = 80

    
    /*  TODO: Figure out how to handle fetchedResultsController
        across different View Controllers. Create a new class? */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCoreData()
        
        fetchedResultsController?.delegate = self
        
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
        shiftView()
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
    
    func shiftView() {
        
        let direction: (CGFloat, CGFloat) -> (CGFloat) = inDeleteMode ? (-) : (+)
        
        mapView.shift(by: ShiftAmount, inDirection: direction)
        deleteModeLabel.shift(by: ShiftAmount, inDirection: direction)
        
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
        
        //Set up FetchRequestController
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
        
    }

    func loadPins() {
        
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do {
            guard let pins = try fetchedResultsController?.managedObjectContext.fetch(request) else {
                throw NSError(domain: "loadPins", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to load entities"])
            }
            
            for pin in pins {
                mapView.addAnnotation(pin)
            }
        } catch let error as NSError {
            dump(error)
        }
    }
    
    func deletePin(_ annotationView: MKAnnotationView) {
        
        if let context = fetchedResultsController?.managedObjectContext,
           let annotation = annotationView.annotation as? NSManagedObject {
            
            context.delete(annotation)
        }
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
            print("In delete mode")
            
        case false:
            //TODO: Navigate to Tourist Photos
            print("Not in delete mode")
        }
    }
}

extension TravelLocationsViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let pin = anObject as? Pin else {
            preconditionFailure("All changes in Map View Controller should be for Pins")
        }
        
        switch type {
        case .insert:
            mapView.addAnnotation(pin)
            
        case .delete:
            mapView.removeAnnotation(pin)
            
        case .update:
            mapView.removeAnnotation(pin)
            mapView.addAnnotation(pin)
            
        case .move:
            fatalError("You can't move pins!")
        }
    }
   }
